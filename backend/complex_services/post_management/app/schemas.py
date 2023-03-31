from datetime import datetime
from typing import Optional

from pydantic import BaseModel
from fastapi import UploadFile


class PostBase(BaseModel):
    # this is the base class for PostCreate and PostUpdate
    title: str
    post_desc: str
    location_latitude: float
    location_longitude: float
    total_reservations: int
    time_end: datetime


class PostCreate(PostBase):
    # this is the class for creating a new post
    image_file: UploadFile
    user_id: int


class Post(PostBase):
    # this is the class for returning a post
    user_id: int
    post_id: int
    available_reservations: Optional[int] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    is_available: bool
    image_url: str


class CreatedPost(Post):
    # this is the class for returning a created post
    users: list


class PostUserView(Post):
    # this is the class for returning a post for a user
    reserved: bool


class NearbyPost(PostUserView):
    # this is the class for returning a nearby post
    distance: float
    post_desc: Optional[str] = None


class PostUpdate(PostBase):
    title: Optional[str] = None
    post_desc: Optional[str] = None
    image_file: Optional[UploadFile] = None
    location_latitude: Optional[float] = None
    location_longitude: Optional[float] = None
    total_reservations: Optional[int] = None
    time_end: Optional[datetime] = None
    is_available: Optional[bool] = None
