import os
import redis
from functools import wraps
from datetime import timedelta
from fastapi.responses import JSONResponse
import json

redis_client = redis.Redis(
    host=os.getenv("RESERVATION_REDIS_SERVER", "host.docker.internal"),
    port=os.getenv("RESERVATION_REDIS_PORT", 6379),
)


def cache(key, ttl=60, tags=None):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # construct the Redis key
            db = kwargs.pop('db', None)
            redis_key = f'{key}:{args}:{kwargs}'
            kwargs['db'] = db

            # check if the data is cached in Redis
            cached_data = redis_client.get(redis_key)

            if cached_data:
                # if the data is cached, deserialize and return it
                response_data = json.loads(cached_data)
                response = JSONResponse(
                    content=response_data,
                    headers={
                        "X-Cache-Status": "HIT",
                        "X-Cache-TTL-Remaining": str(redis_client.ttl(redis_key))
                    })
            else:
                # if the data is not cached, retrieve it and cache it
                response_data = func(*args, **kwargs)
                serialized_data = json.dumps(response_data)

                # serialize the data and cache it in Redis with the specified TTL
                redis_client.set(redis_key, serialized_data, ex=timedelta(seconds=ttl))

                # create the response with the data and a MISS cache status header
                response = JSONResponse(content=response_data, headers={"X-Cache-Status": "MISS"})

                # associate the key with tags
                for tag in wrapper.tags:
                    redis_client.sadd(tag, redis_key)

                for var, value in kwargs.items():
                    tag = var + '-' + str(value)
                    if var != 'db':
                        redis_client.sadd(tag, redis_key)

            return response

        # add tags to the wrapper function
        wrapper.tags = set(tags) if tags else set()

        return wrapper

    return decorator


def invalidate(*tags):
    # get all keys associated with the tags
    keys_to_delete = set()

    for tag in tags:
        keys_to_delete.update(redis_client.smembers(tag))

    # delete the cache entries associated with the keys
    if not keys_to_delete:
        return

    redis_client.delete(*keys_to_delete)

    # delete the tags
    redis_client.delete(*tags)
