from datetime import datetime
from typing import Optional

from pydantic import BaseModel

class UserCredentials(BaseModel):
    password: str 

class UserCredentialsCreate(UserCredentials):
    email: str

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


class AccountCreate(AccountBase):
    # this is the class for creating a new Account
    # ONLY EDIT IF YOUR CREATE HAS FANCY STUFF
    password: str


class AccountUpdate(AccountBase):
    # in case you want to update only some fields
    # EDIT THIS SO IT HAS ALL THE FIELDS YOU WANT TO UPDATE
    pass


# class AccountInDBBase(AccountBase):
#     # this is the base class for AccountInDB and AccountUpdateInDB
#     # SHOULD NOT NEED TO EDIT THIS
#     Account_id: Optional[
#         int
#     ] = None  # this is optional so we can let the DB auto-increment the id

#     class Config:
#         orm_mode = True


class Account(AccountBase):
    # this is the class for returning a Account
    # SHOULD NOT NEED TO EDIT THIS
    dateCreated: datetime
    pass
