from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class PostBase(BaseModel):
    # this is the base class for PostCreate and PostUpdate
    # EDIT THIS
    title: str
    user_id: int
    image_url: str
    location_latitude: float
    location_longitude: float
    available_reservations: int
    total_reservations: int
    time_end: datetime


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
    reservation_id: Optional[
        int
    ] = None  # this is optional so we can let the DB auto-increment the id

    class Config:
        orm_mode = True


class Post(PostInDBBase):
    # this is the class for returning a reservation
    # SHOULD NOT NEED TO EDIT THIS
    post_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    is_available: bool
