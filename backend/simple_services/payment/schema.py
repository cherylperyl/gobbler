from pydantic import BaseModel

class UserBase(BaseModel):
    stripe_user_id: str | None = None
    subscription: str | None = None

class UserCreate(UserBase):
    id: str | None

class User(UserBase):
    id: str

    class Config:
        orm_mode = True