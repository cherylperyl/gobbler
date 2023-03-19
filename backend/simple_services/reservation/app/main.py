from typing import List

from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy.orm import Session

from . import crud, models, schemas
from .database import SessionLocal, engine

from fastapi.responses import JSONResponse


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


@app.get("/ping")
def ping():
    """
    Health check endpoint
    """
    return {"ping": "pong!"}


@app.get("/reservations/all", response_model=List[schemas.Reservation])
def get_all_reservations(db: Session = Depends(get_db)):
    """
    Get all reservations
    """
    reservations = crud.get_all(db)
    if not reservations:
        raise HTTPException(status_code=404, detail="No reservations found")
    return reservations


@app.get("/reservations/{reservation_id}", response_model=schemas.Reservation)
def get_reservation_by_reservation_id(
    reservation_id: int, db: Session = Depends(get_db)
):
    """
    Get reservation by reservation_id
    """
    db_reservation = crud.get_reservation_by_reservation_id(reservation_id, db)
    if db_reservation is None:
        raise HTTPException(status_code=404, detail="Reservation not found")
    return db_reservation


@app.get("/reservations/post/{post_id}", response_model=List[schemas.Reservation])
def get_reservations_by_post_id(post_id: int, db: Session = Depends(get_db)):
    """
    Get reservations by post_id
    """
    reservations = crud.get_reservations_by_post_id(post_id, db)
    if not reservations:
        raise HTTPException(status_code=404, detail="No reservations found")
    return reservations

@app.get("/reservations/user/{user_id}", response_model=List[schemas.Reservation])
def get_reservations_by_user_id(user_id: int, db: Session = Depends(get_db)):
    """
    Get reservations by user_id
    """
    reservations = crud.get_reservations_by_user_id(user_id, db)
    if not reservations:
        raise HTTPException(status_code=404, detail="No reservations found")
    return reservations

@app.get("/reservations/post/slots/{post_id}")
def get_reservations_by_post_id(post_id: int, db: Session = Depends(get_db)):
    """
    Get number of reservations by post_id
    """
    reservations = crud.get_reservations_by_post_id(post_id, db)
    if not reservations:
        raise HTTPException(status_code=404, detail="Invalid Post ID")
    return len(reservations)


@app.post("/reservations/post/slots")
def get_reservations_by_list_of_post_id(post_id_list: int, db: Session = Depends(get_db)):
    """
    Get number of reservations by a list of post_ids
    """
    reservation_numbers=[]

    for post_id in post_id_list:
        reservations = crud.get_reservations_by_post_id(post_id, db)
        if not reservations:
            reservation_numbers.append("Invalid Post ID")
        else:
            reservation_numbers.append(len(reservations))

    return reservation_numbers


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
