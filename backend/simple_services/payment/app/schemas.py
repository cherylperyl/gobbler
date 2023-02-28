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

class EventData(BaseModel):
    object: object 
    previous_attributes: object | None = None

class StripeEvent(BaseModel):
    id: str
    api_version: str
    data: EventData
    request: object
    type: str
    object: str
    account: str | None
    created: int
    livemode: bool
    pending_webhooks: int