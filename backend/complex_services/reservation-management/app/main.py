from typing import List

from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy.orm import Session

from . import crud, models, schemas
from .database import SessionLocal, engine

from fastapi.responses import JSONResponse
import os
from datetime import datetime
import requests

########### DO NOT MODIFY BELOW THIS LINE ###########
# create tables
models.Base.metadata.create_all(bind=engine)

# create FastAPI app
app = FastAPI()


# catch all exceptions and return error message
@app.exception_handler(Exception)
async def all_exception_handler(request, exc):
    return JSONResponse(
        status_code=500, content={"message": request.url.path + " " + str(exc)}
    )


# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


########### DO NOT MODIFY ABOVE THIS LINE ###########

RESERVATION_MS_SERVER = os.getenv("RESERVATION_MS_SERVER")
RESERVATION_MS_PORT = os.getenv("RESERVATION_MS_PORT")
POST_MS_SERVER = os.getenv("POST_MS_SERVER")
POST_MS_PORT = os.getenv("POST_MS_PORT")

reservation_ms_url = "http://" + RESERVATION_MS_SERVER + ":" + RESERVATION_MS_PORT + "/reservations"
post_ms_url = "http://" + POST_MS_SERVER + ":" + POST_MS_PORT + "/graphql"

@app.get("/ping")
def ping():
    """
    Health check endpoint
    """
    return {"ping": "pong!"}


@app.post("/reserve/{post_id}/user/{user_id}", response_model=schemas.Reservation)
def create_reservation(
    post_id: int,
    user_id: int,
    reservation: schemas.ReservationCreate
):
    """
    Create a new reservation
    """
    reservation.user_id = user_id
    reservation.post_id = post_id
    reservation.dateCreated = datetime.now()
    reservation.lastUpdated = datetime.now()

    response = requests.post(
        f"{reservation_ms_url}/api/reservations",
        data = reservation
    )
    if response.status_code not in range(200, 300):
        raise HTTPException(response.status_code, detail = response.text)
    
    return response

#incomplete, waiting for thad first
@app.get("/reservations/{user_id}")
def get_all_posts_reserved_by_user(user_id: int):
    post_ids = requests.get(
        f"{reservation_ms_url}/api/reservations/{user_id}"
    )
    if post_ids.status_code not in range(200, 300):
        raise HTTPException(post_ids.status_code, detail = post_ids.text)
    
    post_list = []

    for id in post_ids:
        query = f"""
                    query {{
                        post(post_id:id){{
                            user_id,
                            post_id, 
                            title,
                            image_url,
                            location_latitude,
                            location_longitude,
                            available_reservations,
                            total_reservations,
                            created_at,
                            time_end,
                            updated_at,
                            is_available
                        }}
                    }}
                """
        payload = {"query": query}
        r = requests.get(post_ms_url, params=payload)
        nearby_posts = r.json()["data"]["nearby_posts"]


    return post_list

