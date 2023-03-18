from typing import List

from fastapi import Depends, FastAPI, HTTPException
from . import schemas
from fastapi.responses import JSONResponse
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

########### DO NOT MODIFY ABOVE THIS LINE ###########

sample_post = {
    "title": "Sample Post",
    "user_id": 1,
    "image_url": "https://picsum.photos/id/237/200/300",
    "location_latitude": 1.0,
    "location_longitude": 1.0,
    "available_reservations": 1,
    "total_reservations": 1,
    "time_end": datetime.now(),
}


@app.get("/ping")
def ping():
    """
    Health check endpoint
    """
    return {"ping": "pong!"}


@app.post("/createpost", response_model=schemas.Post)
def create_post(
    post: schemas.PostCreate
):
    """
    Create a new post.
    """

    # create post with post microservice
    url = "http://localhost:8000/graphql"
    post = sample_post
    query = f"""
                mutation {{
                    create_post(post: {post}) {{
                        post_id,
                        title,
                        user_id,
                        image_url,
                        location_latitude,
                        location_longitude,
                        available_reservations,
                        total_reservations,
                        time_end,
                        created_at,
                        updated_at,
                        is_available
                    }}
                }}
            """
    payload = {"query": query}
    r = requests.post(url, json=payload)

    return r.json()


# @app.get("/reservations/all", response_model=List[schemas.Reservation])
# def get_all_reservations(db: Session = Depends(get_db)):
#     """
#     Get all reservations
#     """
#     reservations = crud.get_all(db)
#     if not reservations:
#         raise HTTPException(status_code=404, detail="No reservations found")
#     return reservations


# @app.get("/reservations/{reservation_id}", response_model=schemas.Reservation)
# def get_reservation_by_reservation_id(
#     reservation_id: int, db: Session = Depends(get_db)
# ):
#     """
#     Get reservation by reservation_id
#     """
#     db_reservation = crud.get_reservation_by_reservation_id(reservation_id, db)
#     if db_reservation is None:
#         raise HTTPException(status_code=404, detail="Reservation not found")
#     return db_reservation


# @app.get("/reservations/post/{post_id}", response_model=List[schemas.Reservation])
# def get_reservations_by_post_id(post_id: int, db: Session = Depends(get_db)):
#     """
#     Get reservations by post_id
#     """
#     reservations = crud.get_reservations_by_post_id(post_id, db)
#     if not reservations:
#         raise HTTPException(status_code=404, detail="No reservations found")
#     return reservations


# @app.post("/reservations", response_model=schemas.Reservation)
# def create_reservation(
#     reservation: schemas.ReservationCreate, db: Session = Depends(get_db)
# ):
#     """
#     Create a new reservation
#     """
#     db_reservation = crud.create_reservation(reservation, db)
#     return db_reservation


# @app.put("/reservations/{reservation_id}", response_model=schemas.Reservation)
# def update_reservation(
#     reservation_id: int,
#     reservation: schemas.ReservationUpdate,
#     db: Session = Depends(get_db),
# ):
#     """
#     Update a reservation
#     """
#     db_reservation = crud.get_reservation_by_reservation_id(reservation_id, db)
#     if db_reservation is None:
#         raise HTTPException(status_code=404, detail="Reservation not found")
#     return crud.update_reservation(db, db_reservation, reservation)


# @app.delete("/reservations/{reservation_id}", response_model=schemas.Reservation)
# def delete_reservation(reservation_id: int, db: Session = Depends(get_db)):
#     """
#     Delete a reservation
#     """
#     db_reservation = crud.get_reservation_by_reservation_id(reservation_id, db)
#     if db_reservation is None:
#         raise HTTPException(status_code=404, detail="Reservation not found")
#     deleted_reservation = crud.delete_reservation(db, db_reservation)
#     return deleted_reservation
