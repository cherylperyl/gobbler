import requests
import os

from . import schema

USER_MGT_ENDPOINT = os.environ.get("USER_MGT_ENDPOINT") if os.environ.get("USER_MGT_ENDPOINT") is not None else "http://localhost:8000"

def update_user(user: schema.UserUpdate) -> requests.Response:
    # patch request to user management ms 
    patch_data = user.dict()
    return requests.patch(
        f"{USER_MGT_ENDPOINT}/user/{user.userId}",
        json=patch_data
    )
