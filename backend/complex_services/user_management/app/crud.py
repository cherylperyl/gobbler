# from typing import Any, Dict, Union, List
from datetime import datetime
from fastapi import HTTPException
from fastapi.encoders import jsonable_encoder
import requests
import os
import json
from dateutil import parser

from . import schemas

endpoint = os.environ.get("USER_ENDPOINT") if os.environ.get("USER_ENDPOINT") is not None else "http://localhost:8081"

def create_account(
    account: schemas.AccountCreate
) -> schemas.Account | dict:
        
    account.dateCreated = datetime.now()
    account.lastUpdated = datetime.now()

    post_data = account.dict()

    # format dates to what user ms expects  
    post_data["dateCreated"] = json.dumps(account.dateCreated.isoformat(), default=str)[1:-4]+'Z'
    post_data["lastUpdated"] = json.dumps(account.lastUpdated.isoformat(), default=str)[1:-4]+'Z'

    # call User MS to create new user 
    response = requests.post(
        f"{endpoint}/api/User",
        json = post_data
    )

    if response.status_code not in range(200, 300):
        raise HTTPException(response.status_code, detail = response.text)
        
    user_data = response.json()
    # convert dates to enable pydantic parsing 
    user_data["lastUpdated"] = parser.parse(user_data["lastUpdated"])
    user_data["dateCreated"] = parser.parse(user_data["dateCreated"])

    return schemas.Account.parse_obj(user_data)
        

def get_account(user_id: int) -> schemas.Account:
    user_response = requests.get(f"{endpoint}/api/User/{user_id}")
    
    if user_response.status_code not in range(200, 300):
        raise HTTPException(user_response.status_code, user_response.text)
    
    user_json = user_response.json()
    
    return schemas.Account(
        userId = user_json["userId"],
        isPremium = user_json["isPremium"],
        username = user_json["username"],
        lastUpdated = parser.parse(user_json["lastUpdated"]).replace(tzinfo=None),
        dateCreated = parser.parse(user_json["dateCreated"]).replace(tzinfo=None),
        email = user_json["email"]
    )

def update_account(user_id: int, patch_user: schemas.AccountCreate) -> schemas.Account:
    user = get_account(user_id)

    patch_user.lastUpdated = datetime.now(tz=None)
    patch_user.userId = user_id

    patch_data = patch_user.dict(exclude_unset = True)
    # print(patch_data)
    updated_item = user.copy(update = patch_data)

    put_data = updated_item.dict()
    # format dates to what user ms expects 
    put_data["lastUpdated"] = updated_item.lastUpdated.isoformat(timespec="milliseconds")+"Z"
    put_data["dateCreated"] = updated_item.dateCreated.isoformat(timespec="milliseconds")+"Z"

    put_response = requests.put(
        f"{endpoint}/api/User", 
        json = put_data)
    
    if put_response.status_code not in range (200, 300):
        raise HTTPException(put_response.status_code, put_response.text)

    # duplicate code, should refactor this out at some point 
    user_data = put_response.json()
    # convert dates to enable pydantic parsing 
    if len(user_data) == 0:
        raise HTTPException(400, "User not found")
    
    user_data = user_data[0]
    user_data["lastUpdated"] = parser.parse(user_data["lastUpdated"])
    user_data["dateCreated"] = parser.parse(user_data["dateCreated"])

    # print(user_data)

    return schemas.Account.parse_obj(user_data)
    
