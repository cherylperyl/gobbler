import logging
from fastapi import FastAPI, Request, status, Depends
from fastapi.responses import RedirectResponse
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
import stripe 
from os import environ

from stripe_model import StripeEvent
from crud import get_all_users, create_user, get_user
import schema 
import models
from db import SessionLocal, engine

models.Base.metadata.create_all(bind=engine)
stripe.api_key = environ.get("stripe_api_key")

app = FastAPI()

def get_db():
    db = SessionLocal()
    try: 
        yield db
    finally:   
        db.close()

@app.get("/users")
async def get_users(db: Session = Depends(get_db)):
    return get_all_users(db = db)

# GET request functionality is there for easy testing from browser. Actual app should only accept POST requests.
# TODO - change redirect URLs to actual frontend URLs
@app.get("/create-checkout-session")
@app.post("/create-checkout-session")
async def create_checkout_session():
    '''Returns a redirect to send user to checkout page.'''
    try:
        price = stripe.Price.retrieve(
            "price_1Mg4I5CmAo6VxEslaX2e93Na"
        )
    
        checkout_session = stripe.checkout.Session.create(
            line_items = [
                {
                    "price": price.id,
                    "quantity": 1
                }
            ],
            mode = "subscription",
            success_url = "http://localhost:5000/users?session_id={CHECKOUT_SESSION_ID}", 
            cancel_url = "http://localhost:5000/cancel" 
        )
        return RedirectResponse(checkout_session.url, status_code= 303)

    except Exception as e:
        print(e)
        return e, 500

# stripe calls this webhook. when payment is successful, save the payment data 
@app.post("/webhook")
async def webhook_received(event: StripeEvent, db: Session = Depends(get_db)): 

    webhook_secret = ""  # TODO - set up secret validation for webhook to filter out spoofed requests 

    if event.type == "customer.subscription.created":
    #     # create db entries 
        print(f"Subscription # {event.data.object['id']} created for stripe id {event.data.object['customer']}")
        user = schema.UserCreate(
            stripe_user_id = event.data.object["customer"],
            subscription = event.data.object['id']
            )
        print(create_user(db = db, user=user))
    
    return 200

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
	exc_str = f'{exc}'.replace('\n', ' ').replace('   ', ' ')
	logging.error(f"{request}: {exc_str}")
	content = {'status_code': 10422, 'message': exc_str, 'data': None}
	return JSONResponse(content=content, status_code=status.HTTP_422_UNPROCESSABLE_ENTITY)