import os
import time

from fastapi import HTTPException
from contextlib import ContextDecorator
import redis

print(os.environ.get("RESERVATION_MANAGEMENT_REDIS_SERVER"))
print(os.environ.get("RESERVATION_MANAGEMENT_REDIS_PORT"))
redis_client = redis.Redis(
    host=os.environ.get("RESERVATION_MANAGEMENT_REDIS_SERVER"),
    port=os.environ.get("RESERVATION_MANAGEMENT_REDIS_PORT"),
)


class LockManager(ContextDecorator):
    def __init__(self, key, timeout=10, retries=5, retry_delay=1):
        self.key = key
        self.timeout = timeout
        self.lock = redis_client.lock(self.key, timeout=self.timeout)
        self.retries = retries
        self.retry_delay = retry_delay
        self.lock_acquired = False

    def __enter__(self):
        attempts = 0
        while attempts < self.retries:
            acquired = self.lock.acquire(blocking=False)
            if acquired:
                self.lock_acquired = True
                return self
            attempts += 1
            time.sleep(self.retry_delay)
        raise HTTPException(status_code=400, detail="Could not acquire lock")

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.lock_acquired:
            self.lock.release()
            self.lock_acquired = False
        return False


def get_lock(key, retries=3, retry_delay=1):
    lock = redis_client.lock(key)
    attempts = 0
    print("Attempting to acquire lock")
    while attempts < retries:
        with lock.acquire(blocking=False) as acquired:
            if acquired:
                print("Lock acquired")
                return lock
            attempts += 1
            time.sleep(retry_delay)

    raise HTTPException(status_code=400, detail="Could not acquire lock")
