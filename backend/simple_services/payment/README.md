# Payment Microservice 
Tracks app premium users and their subscriptions. Links app user ID with Stripe User ID and Stripe subscription ID. 

___
## Endpoints 
`POST /create-checkout-session`

Called by client when the frontend subscription button is placed. Returns a redirect to Stripe's checkout page.

Client app should pass in redirect URL so Stripe knows where to redirect the user upon success 
___
## Setup 
To test locally, download the [Stripe CLI](https://stripe.com/docs/stripe-cli) and set it to forward events to the app 

`stripe listen --forward-to localhost:5006/webhook`

You can then trigger Stripe events to simulate successful subscriptions 

`stripe trigger customer.subscription.created`

When deployed, a Stripe account will be set up to forward customer.subscription.created events to the deployed endpoint 

## To run 
`docker compose up`

Create a post request to http://localhost:5006/create-checkout-session. The server returns a redirect to a Stripe subscription checkout page. Enter testing payment details (card number 4242 4242 4242 4242) plus a validly formatted email and an expiry date in the future. You are then redirected to a success page (currently set to this server's list all users page for convenience, but should be changed to an actual success page on the frontend).

For convenience, the app will also print out the redirect URL in case Postman or the FastAPI docs doesn't redirect you to the redirect URL 

## Todos
- Setup webhook secret in app.py
- Integrate properly with user management ms (how to link to it?)
