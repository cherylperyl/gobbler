from typing import List

from fastapi import Depends, FastAPI, HTTPException
from . import schemas
from fastapi.responses import JSONResponse
import os
import json
from datetime import datetime
import requests

from .redis import LockManager

########### DO NOT MODIFY BELOW THIS LINE ###########

# create FastAPI app
app = FastAPI()


# catch all exceptions and return error message
@app.exception_handler(Exception)
async def all_exception_handler(request, exc):
    return JSONResponse(
        status_code=500, content={"message": request.url.path + " " + str(exc)}
    )


########### DO NOT MODIFY ABOVE THIS LINE ###########

RESERVATION_MS_SERVER = os.getenv("RESERVATION_MS_SERVER")
RESERVATION_MS_PORT = os.getenv("RESERVATION_MS_PORT")
POST_MS_SERVER = os.getenv("POST_MS_SERVER")
POST_MS_PORT = os.getenv("POST_MS_PORT")

reservation_ms_url = (
    "http://" + RESERVATION_MS_SERVER + ":" + RESERVATION_MS_PORT + "/reservations"
)
post_ms_url = "http://" + POST_MS_SERVER + ":" + POST_MS_PORT + "/graphql"


########### HELPER FUNCTIONS ###########
def calculate_available_reservations(post):
    """
    Calculates the number of available reservations for a post.
    """
    global reservation_ms_url

    if post["is_available"]:
        url = f"{reservation_ms_url}/post/slots/{post['post_id']}"
        reservation_count = requests.get(url)
        if reservation_count.status_code == 404:
            reservation_count = 0
        else:
            reservation_count = reservation_count.json()

        return post["total_reservations"] - reservation_count

    else:
        return 0


#######################################


@app.get("/ping")
def ping():
    """
    Health check endpoint
    """
    return {"ping": "pong!"}


@app.post("/reserve", response_model=schemas.Reservation)
def create_reservation(reservation: schemas.ReservationCreate):
    """
    Create a new reservation
    """
    with LockManager(f"post:{reservation.post_id}"):
        query = f"""
            query {{
                post(post_id: {reservation.post_id}) {{
                    post_id,
                    title,
                    post_desc,
                    user_id,
                    image_url,
                    location_latitude,
                    location_longitude,
                    total_reservations,
                    time_end,
                    created_at,
                    updated_at,
                    is_available
                }}
            }}
        """

        payload = {"query": query}
        r = requests.get(post_ms_url, params=payload).json()

        if not r["data"]:
            print(r["errors"])
            return JSONResponse(
                status_code=422, content={"error": "Retrieve of post failed."}
            )
        post = r["data"]["post"]
        if post["user_id"] == reservation.user_id:
            return JSONResponse(
                status_code=403,
                content={"error": "User cannot reserve their own post."},
            )

        if not post["is_available"]:
            return JSONResponse(
                status_code=404,
                content={"error": "Post is no longer available for reservations."},
            )

        reservations_resp = requests.get(
            f"{reservation_ms_url}/post/{reservation.post_id}"
        )
        if reservations_resp.status_code == 404:
            reserved_slots = 0
        elif reservations_resp.status_code == 200:
            reservations = reservations_resp.json()
            current_users = {reservation["user_id"] for reservation in reservations}
            if reservation.user_id in current_users:
                return JSONResponse(
                    status_code=409,
                    content={"error": "User has already registered for this post."},
                )
            else:
                reserved_slots = len(reservations)
        else:
            return JSONResponse(
                status_code=500,
                content={"error": "Error retrieving reservations for post."},
            )

        if reserved_slots >= post["total_reservations"]:
            return JSONResponse(
                status_code=404,
                content={"error": "Post is no longer available for reservations."},
            )

        response = requests.post(reservation_ms_url, json=reservation.dict())
        if response.status_code not in range(200, 300):
            raise HTTPException(response.status_code, detail=response.text)

        return response.json()


@app.get("/reservations/all/{user_id}", response_model=List[schemas.Reservation])
def get_all_posts_reserved_by_user(user_id: int):
    url = f"{reservation_ms_url}/user/{user_id}"
    reservations = requests.get(url)

    # return empty list if user has no reservations
    if reservations.status_code == 404:
        return []

    reservations = reservations.json()

    post_ids = {reservation["post_id"] for reservation in reservations}

    query = f"""
                query {{
                    posts_from_ids(post_ids:{post_ids}){{
                        user_id,
                        post_id,
                        title,
                        post_desc,
                        image_url,
                        location_latitude,
                        location_longitude,
                        total_reservations,
                        created_at,
                        time_end,
                        updated_at,
                        is_available
                    }}
                }}
            """

    payload = {"query": query}
    r = requests.get(post_ms_url, params=payload).json()

    if not r["data"]:
        print(r["errors"])
        return JSONResponse(
            status_code=422, content={"error": "Retrieve of posts failed."}
        )

    posts = r["data"]["posts_from_ids"]

    url = f"{reservation_ms_url}/posts/slots"
    response = requests.get(url, json=post_ids).json()

    for i in range(len(response)):
        reservations[i]["post"] = posts[i]
        reservations[i]["post"]["available_reservations"] = (
            reservations[i]["post"]["total_reservations"] - response[i]
        )

    return reservations


@app.delete("/reserve/cancel", response_model=schemas.Reservation)
def delete_reservation(reservation_id: int):
    response = requests.delete(f"{reservation_ms_url}/{reservation_id}")
    if response.status_code not in range(200, 300):
        raise HTTPException(response.status_code, detail=response.text)

    deleted_reservation = response.json()

    return deleted_reservation
