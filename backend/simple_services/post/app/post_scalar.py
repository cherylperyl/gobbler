import strawberry
from datetime import datetime
from strawberry.file_uploads import Upload
from typing import Optional

@strawberry.input
class PostInput:
    user_id: int
    title: str
    post_desc: str
    image_file: Upload
    location_latitude: float
    location_longitude: float
    total_reservations: int
    time_end: datetime
    file_name: str

@strawberry.type
class Post:
    user_id: int
    title: str
    post_desc: str
    location_latitude: float
    location_longitude: float
    total_reservations: int
    time_end: datetime
    created_at: datetime
    updated_at: Optional[datetime]
    post_id: int
    is_available: bool
    image_url: str

@strawberry.type
class PostNearby(Post):
    distance: float

@strawberry.input
class PostUpdate:
    title: Optional[str] = None
    post_desc: Optional[str] = None
    image_file: Optional[Upload] = None
    location_latitude: Optional[float] = None
    location_longitude: Optional[float] = None
    total_reservations: Optional[int] = None
    time_end: Optional[datetime] = None
    is_available: Optional[bool] = None
    file_name: Optional[str] = None
    image_url: Optional[str] = None
