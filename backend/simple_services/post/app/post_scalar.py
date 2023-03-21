import strawberry
import datetime
import typing
from strawberry.file_uploads import Upload

@strawberry.input 
class PostInput:
    user_id: int
    title: str
    image_file: Upload
    location_latitude: float
    location_longitude: float
    available_reservations: int
    total_reservations: int
    time_end: datetime.datetime

@strawberry.type
class Post(PostInput):
    created_at: datetime.datetime
    updated_at: typing.Optional[datetime.datetime]
    post_id: int
    is_available: bool
    
@strawberry.type
class PostNearby(Post):
    distance: float

@strawberry.input
class PostUpdate:
    title: typing.Optional[str] = None
    image_file: typing.Optional[Upload] = None
    location_latitude: typing.Optional[float] = None
    location_longitude: typing.Optional[float] = None
    available_reservations: typing.Optional[int] = None
    total_reservations: typing.Optional[int] = None
    time_end: typing.Optional[datetime.datetime] = None
    is_available: typing.Optional[bool] = None
