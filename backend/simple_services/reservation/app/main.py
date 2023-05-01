from typing import List

from fastapi import Depends, FastAPI, HTTPException, Request, Response
from sqlalchemy.orm import Session

from . import crud, models, schemas
from .database import SessionLocal, engine

from fastapi.responses import JSONResponse
from fastapi_redis_cache import FastApiRedisCache, cache_one_minute
from fastapi.encoders import jsonable_encoder
import os


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


@app.on_event("startup")
def startup():
    """
    Initialize Redis
    """
    redis_cache = FastApiRedisCache()
    RESERVATION_REDIS_SERVER = os.environ.get("RESERVATION_REDIS_SERVER", "host.docker.internal")
    RESERVATION_REDIS_PORT = os.environ.get("RESERVATION_REDIS_PORT", "6379")
    redis_cache.init(
        host_url=f"redis://{RESERVATION_REDIS_SERVER}:{RESERVATION_REDIS_PORT}",
        prefix="myapi-cache",
        response_header="X-MyAPI-Cache",
        ignore_arg_types=[Request, Response, Session]
    )


@app.get("/ping")
@cache_one_minute()
async def ping(
    response: Response
):
    """
    Health check endpoint
    """
    return {"ping": "pong"}


@app.get("/reservations/all", response_model=List[schemas.Reservation])
@cache_one_minute()
def get_all_reservations(
    response: Response,
    db: Session = Depends(get_db)
):
    """
    Get all reservations
    """
    reservations = crud.get_all(db)
    if not reservations:
        raise HTTPException(status_code=404, detail="No reservations found")
    return jsonable_encoder(reservations)


@app.get("/reservations/{reservation_id}", response_model=schemas.Reservation)
@cache_one_minute()
def get_reservation_by_reservation_id(
    response: Response,
    reservation_id: int,
    db: Session = Depends(get_db)
):
    """
    Get reservation by reservation_id
    """
    db_reservation = crud.get_reservation_by_reservation_id(reservation_id, db)
    if db_reservation is None:
        raise HTTPException(status_code=404, detail="Reservation not found")
    return jsonable_encoder(db_reservation)


@app.get("/reservations/post/{post_id}", response_model=List[schemas.Reservation])
@cache_one_minute()
def get_reservations_by_post_id(
    response: Response,
    post_id: int,
    db: Session = Depends(get_db)
):
    """
    Get reservations by post_id
    """
    reservations = crud.get_reservations_by_post_id(post_id, db)
    if not reservations:
        raise HTTPException(status_code=404, detail="No reservations found")
    return jsonable_encoder(reservations)


@app.get("/reservations/user/{user_id}", response_model=List[schemas.Reservation])
@cache_one_minute()
def get_reservations_by_user_id(
    response: Response,
    user_id: int,
    db: Session = Depends(get_db)
):
    """
    Get reservations by user_id
    """
    reservations = crud.get_reservations_by_user_id(user_id, db)
    if not reservations:
        raise HTTPException(status_code=404, detail="No reservations found")
    return jsonable_encoder(reservations)


@app.get("/reservations/post/slots/{post_id}")
@cache_one_minute()
def get_reservation_count_by_post_id(
    response: Response,
    post_id: int,
    db: Session = Depends(get_db)
):
    """
    Get number of reservations by post_id
    """
    reservations_count = crud.get_reservation_count_by_post_id(post_id, db)
    if not reservations_count:
        raise HTTPException(status_code=404, detail="Invalid Post ID")
    return reservations_count


@app.get("/reservations/posts/slots")
def get_reservations_by_list_of_post_id(
    response: Response,
    post_id_list: List[int],
    db: Session = Depends(get_db)
):
    """
    Get number of reservations by a list of post_ids
    """
    reservation_numbers = []

    for post_id in post_id_list:
        reservations_count = crud.get_reservation_count_by_post_id(post_id, db)
        if not reservations_count:
            reservation_numbers.append(0)
        else:
            reservation_numbers.append(reservations_count)

    return jsonable_encoder(reservation_numbers)


@app.get("/reservations/user/{user_id}/post/{post_id}", response_model=schemas.Reservation)
@cache_one_minute()
def get_reservation_by_user_id_and_post_id(
    response: Response,
    user_id: int,
    post_id: int,
    db: Session = Depends(get_db)
):
    """
    Get reservation by user_id and post_id
    """
    reservation = crud.get_reservation_by_user_id_and_post_id(user_id, post_id, db)
    if not reservation:
        raise HTTPException(status_code=404, detail="No reservations found")
    return jsonable_encoder(reservation)


@app.post("/reservations", response_model=schemas.Reservation)
def create_reservation(
    reservation: schemas.ReservationCreate, db: Session = Depends(get_db)
):
    """
    Create a new reservation
    """
    db_reservation = crud.create_reservation(reservation, db)
    return db_reservation


@app.put("/reservations/{reservation_id}", response_model=schemas.Reservation)
def update_reservation(
    reservation_id: int,
    reservation: schemas.ReservationUpdate,
    db: Session = Depends(get_db),
):
    """
    Update a reservation
    """
    db_reservation = crud.get_reservation_by_reservation_id(reservation_id, db)
    if db_reservation is None:
        raise HTTPException(status_code=404, detail="Reservation not found")
    return crud.update_reservation(db, db_reservation, reservation)


@app.delete("/reservations/{reservation_id}", response_model=schemas.Reservation)
def delete_reservation(reservation_id: int, db: Session = Depends(get_db)):
    """
    Delete a reservation
    """
    db_reservation = crud.get_reservation_by_reservation_id(reservation_id, db)
    if db_reservation is None:
        raise HTTPException(status_code=404, detail="Reservation not found")
    deleted_reservation = crud.delete_reservation(db, db_reservation)
    return deleted_reservation
