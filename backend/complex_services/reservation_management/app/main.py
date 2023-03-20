from typing import List

from fastapi import Depends, FastAPI, HTTPException
from . import schemas
from fastapi.responses import JSONResponse
import os
from datetime import datetime
import requests

########### DO NOT MODIFY BELOW THIS LINE ###########

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


@app.post("/reserve", response_model=schemas.Reservation)
def create_reservation(
    reservation: schemas.ReservationCreate
):
    """
    Create a new reservation
    """
    reservation.user_id = reservation.user_id
    reservation.post_id = reservation.post_id
    reservation.created_at = datetime.now()
    reservation.updated_at = datetime.now()

    response = requests.post(
        f"{reservation_ms_url}/api/reservations",
        data = reservation
    )
    if response.status_code not in range(200, 300):
        raise HTTPException(response.status_code, detail = response.text)
    
    return response

@app.get("/reservations/all/{user_id}", response_model=List[schemas.Reservation])
def get_all_posts_reserved_by_user(user_id: int):
    post_ids = requests.get(
        f"{reservation_ms_url}/api/reservations/{user_id}"
    )
    if post_ids.status_code not in range(200, 300):
        raise HTTPException(post_ids.status_code, detail = post_ids.text)
        
    query = f"""
                query {{
                    post(post_ids:{post_ids}){{
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
    response = requests.get(post_ms_url, params=payload)
    posts_from_ids = response.json()["data"]["posts_from_ids"]

    return posts_from_ids

