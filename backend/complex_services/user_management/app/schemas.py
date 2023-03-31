from datetime import datetime
from typing import Optional

from pydantic import BaseModel

class UserCredentials(BaseModel):
    password: str 

class UserCredentialsCreate(UserCredentials):
    email: str
    username: str

class UserCredentialsLogin(UserCredentials):
    username: str

class AccountBase(BaseModel):
    # this is the base class for AccountCreate and AccountUpdate
    # EDIT THIS
    userId: Optional[int]
    isPremium: Optional[bool] = False
    username: Optional[str] = None
    dateCreated: Optional[datetime] = None
    lastUpdated: Optional[datetime] = None
    email: Optional[str]
    stripeId: Optional[str] = None
    subscriptionId: Optional[str]
    fcmToken: Optional[str] = None


class AccountCreate(AccountBase):
    # this is the class for creating a new Account
    # ONLY EDIT IF YOUR CREATE HAS FANCY STUFF
    password: str


class AccountUpdate(AccountBase):
    # in case you want to update only some fields
    # EDIT THIS SO IT HAS ALL THE FIELDS YOU WANT TO UPDATE
    pass

class Account(AccountBase):
    # this is the class for returning a Account
    # SHOULD NOT NEED TO EDIT THIS
    dateCreated: datetime
    pass

class SubscribeRequest(BaseModel):
    userId: int
    success_url: str
