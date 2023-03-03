from pydantic import BaseModel


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