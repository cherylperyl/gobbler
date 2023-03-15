import requests
import os

from . import schema

USER_MGT_ENDPOINT = os.environ.get("USER_MGT_ENDPOINT") if os.environ.get("USER_MGT_ENDPOINT") is not None else "http://localhost:5005"

def update_user(user: schema.UserUpdate) -> requests.Response:
    # patch request to user_mgt ms 
    patch_data = user.dict()
    return requests.patch(
        f"{USER_MGT_ENDPOINT}/user/{user.userId}",
        data=patch_data
    )
