from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class PostBase(BaseModel):
    # this is the base class for PostCreate and PostUpdate
    # EDIT THIS
    user_id: int
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class PostCreate(PostBase):
    # this is the class for creating a new reservation
    # ONLY EDIT IF YOUR CREATE HAS FANCY STUFF
    pass


class PostUpdate(PostBase):
    # in case you want to update only some fields
    # EDIT THIS SO IT HAS ALL THE FIELDS YOU WANT TO UPDATE
    user_id: Optional[int] = None
    post_id: Optional[int] = None


class PostInDBBase(PostBase):
    # this is the base class for ReservationInDB and ReservationUpdateInDB
    # SHOULD NOT NEED TO EDIT THIS
    post_id: Optional[
        int
    ] = None  # this is optional so we can let the DB auto-increment the id

    class Config:
        orm_mode = True


class Post(PostInDBBase):
    # this is the class for returning a post
    # SHOULD NOT NEED TO EDIT THIS
    # post_id: int
    pass
