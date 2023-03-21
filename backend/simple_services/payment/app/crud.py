from sqlalchemy.orm import Session

from . import models, schema


def get_user(db: Session, user_id: str):
    return db.query(models.User).filter(models.User.id == user_id).first()


def get_all_users(db: Session):
    return db.query(models.User).all()


def create_user(db: Session, user: schema.UserCreate):
    db_user = models.User(
        stripe_user_id=user.stripe_user_id, subscription=user.subscription
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user
