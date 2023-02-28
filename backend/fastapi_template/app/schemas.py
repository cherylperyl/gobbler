from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class ReservationBase(BaseModel):
    # this is the base class for ReservationCreate and ReservationUpdate
    # EDIT THIS
    user_id: int
    post_id: int
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class ReservationCreate(ReservationBase):
    # this is the class for creating a new reservation
    # ONLY EDIT IF YOUR CREATE HAS FANCY STUFF
    pass


class ReservationUpdate(ReservationBase):
    # in case you want to update only some fields
    # EDIT THIS SO IT HAS ALL THE FIELDS YOU WANT TO UPDATE
    user_id: Optional[int] = None
    post_id: Optional[int] = None


class ReservationInDBBase(ReservationBase):
    # this is the base class for ReservationInDB and ReservationUpdateInDB
    # SHOULD NOT NEED TO EDIT THIS
    reservation_id: Optional[
        int
    ] = None  # this is optional so we can let the DB auto-increment the id

    class Config:
        orm_mode = True


class Reservation(ReservationInDBBase):
    # this is the class for returning a reservation
    # SHOULD NOT NEED TO EDIT THIS
    reservation_id: int
