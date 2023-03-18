from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class PostBase(BaseModel):
    # this is the base class for PostCreate and PostUpdate
    title: str
    user_id: int
    image_url: str  # to change to bytes
    location_latitude: float
    location_longitude: float
    available_reservations: int
    total_reservations: int
    time_end: datetime


class PostCreate(PostBase):
    # this is the class for creating a new post
    pass


class Post(PostBase):
    # this is the class for returning a post
    post_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    is_available: bool
