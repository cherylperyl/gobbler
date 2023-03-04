import strawberry
import datetime
import typing

@strawberry.input 
class PostInput:
    user_id: int
    title: str
    image_url: str
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

@strawberry.input
class PostUpdate:
    title: str
    image_url: str
    location_latitude: float
    location_longitude: float
    available_reservations: int
    total_reservations: int
    time_end: datetime.datetime