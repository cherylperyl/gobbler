from sqlalchemy.orm import Session
from typing import Any, Dict, Union, List
from datetime import datetime
from fastapi.encoders import jsonable_encoder
from app.database import SessionLocal
from haversine import haversine
from sqlalchemy import text


import app.models as models, app.post_scalar as post_scalar


def get_all() -> List[models.Post]:
    db = SessionLocal()
    result = db.query(models.Post).filter(models.Post.time_end > datetime.now())
    db.close()
    return result


def get_post_by_post_id(
    post_id: int
) -> models.Post:
    db = SessionLocal()
    result = (
        db.query(models.Post)
        .filter(models.Post.post_id == post_id)
        .first()
    )
    db.close()
    return result

def create_post(
    post: post_scalar.PostInput
) -> models.Post:
    db = SessionLocal()
    db_post = models.Post(**post.__dict__)
    db_post.created_at = datetime.now()
    db_post.updated_at = None
    db_post.is_available = True
    db.add(db_post)
    db.commit()
    db.refresh(db_post)
    return db_post

def update_post(
    db_obj: models.Post,
    obj_in: post_scalar.PostUpdate
) -> models.Post:
    db = SessionLocal()
    obj_data = jsonable_encoder(obj_in)
    for field in jsonable_encoder(db_obj):
        if field in obj_data and obj_data[field] is not None:
            if field == 'time_end':
                obj_data[field] = datetime.strptime(obj_data[field], '%Y-%m-%dT%H:%M:%S')
            setattr(db_obj, field, obj_data[field])
    db_obj.updated_at = datetime.now()
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    db.close()
    return db_obj

def get_nearby_posts(lat: float, long: float) -> List[models.Post]:
    db = SessionLocal()
    query = text("""
    SELECT ( 6371 * acos( cos( radians(:lat) ) * cos( radians( location_latitude ) ) * cos( radians( location_longitude ) - radians(:long) ) + sin( radians(:lat) ) * sin(radians(location_latitude)) ) ) 
    AS distance, 
    title, post_id, user_id, image_url, location_latitude, location_longitude, available_reservations, total_reservations, time_end, created_at, updated_at, is_available
    FROM posts
    WHERE time_end >= NOW()
    HAVING
    distance < 5
    ORDER BY distance;
    """)
    results = db.execute(query, {"lat": lat, "long": long})
    db.close()
    return results

def get_posts_by_user(user_id: int) -> List[models.Post]:
    db = SessionLocal()
    result = db.query(models.Post).filter(models.Post.user_id == user_id)
    db.close()
    return result

def get_posts_by_ids(post_ids: list) -> List[models.Post]:
    db = SessionLocal()
    print(post_ids)
    result = db.query(models.Post).filter(models.Post.post_id.in_(post_ids))
    db.close()
    return result

def delete_post(post: models.Post) -> models.Post:
    db = SessionLocal()
    db.delete(post)
    db.commit()
    db.close()
    return post


