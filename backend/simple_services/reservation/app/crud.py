from sqlalchemy.orm import Session
from typing import Any, Dict, Union, List
from datetime import datetime
from fastapi.encoders import jsonable_encoder

from . import models, schemas


def get_all(db: Session) -> List[models.Reservation]:
    return db.query(models.Reservation).all()


def get_reservation_by_reservation_id(
    reservation_id: int, db: Session
) -> models.Reservation:
    return (
        db.query(models.Reservation)
        .filter(models.Reservation.reservation_id == reservation_id)
        .first()
    )


def get_reservations_by_post_id(post_id: int, db: Session) -> List[models.Reservation]:
    return (
        db.query(models.Reservation).filter(models.Reservation.post_id == post_id).all()
    )


def create_reservation(
    reservation: schemas.ReservationCreate, db: Session
) -> models.Reservation:
    db_reservation = models.Reservation(**reservation.dict())
    db_reservation.created_at = datetime.now()
    db_reservation.updated_at = None
    db.add(db_reservation)
    db.commit()
    db.refresh(db_reservation)
    return db_reservation


def update_reservation(
    db: Session,
    db_obj: models.Reservation,
    obj_in: Union[schemas.ReservationUpdate, Dict[str, Any]],
) -> models.Reservation:
    obj_data = jsonable_encoder(db_obj)
    if isinstance(obj_in, dict):
        update_data = obj_in
    else:
        update_data = obj_in.dict(exclude_unset=True)
    for field in obj_data:
        if field in update_data:
            setattr(db_obj, field, update_data[field])
    db_obj.updated_at = datetime.now()
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj


def delete_reservation(db: Session, reservation: models.Reservation) -> models.Reservation:
    db.delete(reservation)
    db.commit()
    return reservation
