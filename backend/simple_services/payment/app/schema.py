from pydantic import BaseModel


class UserBase(BaseModel):
    stripe_user_id: str = None
    subscription: str = None


class UserCreate(UserBase):
    id: str


class User(UserBase):
    id: str

    class Config:
        orm_mode = True
