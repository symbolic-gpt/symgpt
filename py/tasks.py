from typing import List
from celery import Celery
import os
import logging
from audit.fast import fast_process_sol
from audit.process import process_sol
from log import get_private_file_logger, get_ignored_logger
import uuid
import redis
import time
# Configure Celery to use Redis as the broker
app = Celery('tasks', broker='redis://localhost:6379/0', backend='redis')

logger = logging.getLogger(__name__)

@app.task(track_started = True)
def audit(filepath, ercs, out_dir, no_cache:bool, filter_rule:List[str], filter_rtype:List[str]):
    filename = os.path.basename(filepath).split(".")[0]
    sol_log_file = os.path.join(out_dir, f"{filename}.log")
    sol_logger = get_private_file_logger(sol_log_file, logging.ERROR)

    sol_logger = get_ignored_logger(filename)
    client = redis.Redis(host='localhost', port=6379, db=1)
    lock = RedisLock(client, "my_lock")
    try:
        process_sol(
            filepath,
            out_dir,
            ercs=ercs,
            no_cache=no_cache,
            cname2ercs=None,
            only_rules_at=None,
            logger=sol_logger,
            solc_lock=lock,
            filter_rule=filter_rule,
            filter_rtype=filter_rtype
        )
    except Exception as e:
        sol_logger.error(f"Error: {e}")
        raise e
    
@app.task
def fast_check(filepath, ercs, out_dir):
    fast_process_sol(
        filepath,
        out_dir,
        ercs=ercs,
        cname2ercs=None,
        only_rules_at=None,
        logger=None
    )


class RedisLockTimeoutException(Exception):
    pass

class RedisLock:
    def __init__(self, client: redis.Redis, lock_name:str, expiration=100, retry_interval=1):
        self.client = client
        self.lock_name = lock_name
        self.expiration = expiration
        self.lock_value = str(uuid.uuid4())
        self.retry_interval = retry_interval

    def acquire(self, timeout=100):
        start_time = time.time()
        while True:
            result = self.client.set(self.lock_name, self.lock_value, nx=True, ex=self.expiration)
            if result:
                return True
            elif time.time() - start_time > timeout:
                raise RedisLockTimeoutException(f"Failed to acquire lock within {timeout} seconds")
            time.sleep(self.retry_interval)

    def release(self):
        # Use Lua script to release the lock
        script = """
        if redis.call("get", KEYS[1]) == ARGV[1] then
            return redis.call("del", KEYS[1])
        else
            return 0
        end
        """
        result = self.client.eval(script, 1, self.lock_name, self.lock_value)
        return result == 1