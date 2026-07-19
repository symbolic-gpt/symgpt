from collections import defaultdict
import logging
import os
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed, wait
from glob import glob

from sol.utils import get_contracts_and_ercs, compile

lock = threading.Lock()
logger = logging.getLogger(__name__)


def init_erc_ct_database(sols_dir:str):
    print(sols_dir, os.path.join(sols_dir, "*.sol"))
    sol_files = glob(os.path.join(sols_dir, "*.sol"))
    pool = ThreadPoolExecutor(max_workers=10)
    futures = [pool.submit(summary_sol, sol_file) for sol_file in sol_files]
    db = defaultdict(list)
    for future in as_completed(futures):
        result = future.result()
        for erc, items in result.items():
            db[erc].extend(items)
    pool.shutdown()
    return db



def summary_sol(sol_file:str):
    
    try:
        lock.acquire()
        _, cu = compile(sol_file)
    except Exception as ex:
        cu = None
    finally:
        lock.release()
    if cu is None:
        return {}
    summary = defaultdict(list)
    for c, ercs in get_contracts_and_ercs(cu).items():
        for erc in ercs:            
            summary[erc].append({
                "file": sol_file,
                "contract": c.name
            })
    return summary
    