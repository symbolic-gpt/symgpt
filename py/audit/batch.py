import logging
import signal
import threading
from typing import Dict, List, Tuple
import sys
import celery.result
import celery.states
import tasks
import subprocess
import os
import time
import celery
logger = logging.getLogger(__name__)

def stream_output(pipe, logger_func):
    with pipe:
        for line in iter(pipe.readline, b''):
            logger_func(line.decode().strip())
    logger_func("End of stream")

def get_erc(src):
    with open(src, "r") as f:
        content = f.read()
        if content.find("\"language\": \"Solidity\",") != -1:
            format_err += 1
            raise Exception("Solidity format error")
        if "ERC1155" in content or "erc1155" in content:
            return "1155"
        elif "ERC721" in content or "erc721" in content:
            return "721"
        elif "ERC20" in content or "erc20" in content:
            return "20"
    
    if content.find("event Approval") != -1 and content.find("event Transfer") != -1 and content.find("BEP20") == -1 and content.find("bep20") == -1:
        return "20"
    raise Exception("DEADEND")

def exit_if_error(p: subprocess.Popen):
    logging.info("Waiting for the process to finish")
    ret_val = p.wait()
    logging.info(f"Process {p.pid} finished with return code: {ret_val}")
    if ret_val != 0:
        os._exit(1)

def monitor_task_result(task_results: List[Tuple[str, celery.result.AsyncResult]], process: subprocess.Popen):
    success_count = 0
    # Initialize tracking structures
    task_status = {sol_file: False for sol_file, _ in task_results}
    finished_tasks = set()
    started_tasks = set()
    last_finished_count = 0
    while True:
        all_tasks_finished = True
        
        for sol_file, result in task_results:
            if not result.ready():
                task_status[sol_file] = result.state
                all_tasks_finished = False
            elif sol_file not in finished_tasks:
                if result.successful():
                    logger.info(f"Processing of {sol_file} is done.")
                    task_status[sol_file] = result.state
                    success_count += 1
                else:
                    logger.info(f"Processing of {sol_file} failed. Status: {result.status}")
                    task_status[sol_file] = result.state
                finished_tasks.add(sol_file)
        
        # Report current status
        for sol_file, status in task_status.items():
            if status == celery.states.STARTED:
                if sol_file not in started_tasks:
                    logger.info(f"Task {sol_file} has started.")
                    started_tasks.add(sol_file)
        
        finished_count = len(finished_tasks)
        if finished_count > last_finished_count:
            last_finished_count = finished_count
            logger.info(f"Processed {finished_count}/{len(task_results)} files")
        if all_tasks_finished:
            break
        
        time.sleep(15)  # Wait for 8 seconds before checking again
    
    logger.info(f"Processed {success_count}/{len(task_results)} files successfully")
    
    logger.info("Shutting down the workers")
    process.terminate()
    process.wait()


def batch_process(
    broker_url:str,
    sol_files:List[str], 
    out_dir:str, 
    cname2ercs:Dict = None, 
    ercs:List[str] = None, 
    only_rules_at:Dict[str, List[int]] = None,
    no_cache:bool = False,
    skip_if_result_exits:bool = True,
    concurrency = 4,
    filter_erc:List[str] = None,
    filter_rule:List[str] = None,
    filter_rtype:List[str] = None,
    
):
    logger.info(f"Processing {len(sol_files)} files, ercs: {ercs}, filtering by ERC: {filter_erc}, filter by rule: {filter_rule}, filter by rtype: {filter_rtype}")
    
    bringup_redis().check_returncode()
    process = bringup_celery_workers(broker_url, concurrency)
    def signal_handler(signum, frame):
        logger.info(f'Signal handler called with signal {signum}')
        process.terminate()
        process.wait()
        os._exit(0)

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    threading.Thread(target=stream_output, args=(process.stdout, logger.debug)).start()
    threading.Thread(target=stream_output, args=(process.stderr, logger.debug)).start()
    threading.Thread(target=exit_if_error, args=(process,)).start()

    time.sleep(3)  # Wait for the workers to come up


    result_files = set(["-".join(file.split("-")[:-2]) for file in os.listdir(out_dir) if file.endswith('.json')])

    task_results = []
    skip_count = 0
    filtered_sol_files = []
    ercs_dist = {
        "20": 0,
        "721": 0,
        "1155": 0
    }
    for sol_file in sol_files:
        erc = get_erc(sol_file)
        if filter_erc:
            if erc not in filter_erc:
                continue
        if skip_if_result_exits:
            # Check if the result already exists
            filename = os.path.basename(sol_file).split(".")[0]
            if filename in result_files:
                # logger.info(f"Skipping {sol_file} as the result already exists")
                skip_count += 1
                continue
        filtered_sol_files.append(sol_file)
        ercs_dist[erc] += 1
    
    filtered_sol_files.sort()
    logger.info(f"After filtered, {len(filtered_sol_files)} files are pending to process")
    logger.info(f"ERC distribution: {ercs_dist}")
    
    for sol_file in filtered_sol_files:
        result = tasks.audit.delay(
            sol_file, ercs, out_dir, 
            filter_rule=filter_rule, 
            filter_rtype=filter_rtype, 
            no_cache=no_cache)
        task_results.append((sol_file, result))
        # logger.info(f"Processing {sol_file} with task ID: {result.id}")
    
    logger.info(f"Skipped {skip_count} files")
    logger.info(f"Processing {len(task_results)} files")
    
    threading.Thread(target=monitor_task_result, args=(task_results, process)).start()
    


def bringup_celery_workers(broker_url:str, concurrency=4) -> subprocess.Popen:
    env = dict(os.environ)
    env['CELERY_BROKER_URL'] = broker_url
    env['CELERY_RESULT_BACKEND'] = broker_url
    env['PYTHONPATH'] = "py"
    return subprocess.Popen(
        ['celery', '-A', 'tasks', 'worker', '--loglevel=error', f'--concurrency={concurrency}', '--max-tasks-per-child=1', '--max-memory-per-child=15625000'],
        env=env,
        preexec_fn=os.setsid,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )

def bringup_redis() -> subprocess.CompletedProcess:
    return subprocess.run(
        ['docker-compose', "up", "-d"]
    )