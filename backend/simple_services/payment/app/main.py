import logging
from fastapi import FastAPI, Request, status, Depends, HTTPException
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse, RedirectResponse
import stripe
from os import environ

from .stripe_model import StripeEvent
from . import schema


stripe.api_key = environ.get("STRIPE_API_KEY")

app = FastAPI()


# TODO - change redirect URLs to actual frontend URLs
@app.post("/create-checkout-session")
async def create_checkout_session(checkout_request: schema.CheckoutRequest):
    """Returns a redirect to send user to checkout page."""
    try:
        price = stripe.Price.retrieve("price_1Mg4I5CmAo6VxEslaX2e93Na")

        # metadata will be returned to the webhook so we can connect the stripe details to our internal user id
        checkout_session = stripe.checkout.Session.create(
            line_items=[{"price": price.id, "quantity": 1}],
            mode="subscription",
            success_url=checkout_request.success_url,
            subscription_data={"metadata": {"userId": checkout_request.userId}},
        )
        # printing url so you can follow it during testing
        # print(checkout_session.url)

        return schema.StripeResponse(redirect_url=checkout_session.url)

    except Exception as e:
        print(e)
        raise HTTPException(500, e)


# stripe calls this webhook. when payment is successful, save the payment data
@app.post("/webhook")
async def process_webhook(event: StripeEvent):
    webhook_secret = (
        ""  # TODO - set up secret validation for webhook to filter out spoofed requests
    )

    # TODO - handle unsubscribe event
    if event.type == "customer.subscription.created":
        return JSONResponse(
            content={"userId": event.data.object["metadata"]["userId"]}, status_code=200
        )
    return JSONResponse(
        {"message": "Unhandled event type: {}".format(event.type)}, status_code=403
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    exc_str = f"{exc}".replace("\n", " ").replace("   ", " ")
    logging.error(f"{request}: {exc_str}")
    content = {"status_code": 422, "message": exc_str, "data": None}
    return JSONResponse(
        content=content, status_code=status.HTTP_422_UNPROCESSABLE_ENTITY
    )
