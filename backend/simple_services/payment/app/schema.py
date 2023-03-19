from typing import Optional
from pydantic import BaseModel


class UserBase(BaseModel):
    userId: Optional[int] = None
    isPremium: Optional[bool] = False
    stripeId: Optional[str] = None
    subscriptionId: Optional[str] = None


class UserUpdate(UserBase):
    userId: int
    isPremium: bool
    stripeId: str
    subscriptionId: str


class CheckoutRequest(BaseModel):
    userId: int
    success_url: str