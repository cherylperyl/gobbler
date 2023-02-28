from sqlalchemy.orm import Session

import app.models as models
import app.schemas as schemas


def get_user(db: Session, user_id: str):
    return db.query(models.User).filter(models.User.id == user_id).first()

def get_all_users(db: Session):
    return db.query(models.User).all()

def create_user(db: Session, user: schemas.UserCreate):
    db_user = models.User(stripe_user_id = user.stripe_user_id, subscription = user.subscription)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user