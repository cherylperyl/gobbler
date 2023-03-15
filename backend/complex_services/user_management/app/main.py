from typing import List

from fastapi import Depends, FastAPI, HTTPException

from . import crud, schemas

from fastapi.responses import JSONResponse


########### DO NOT MODIFY BELOW THIS LINE ###########

# create FastAPI app
app = FastAPI()


# catch all exceptions and return error message
@app.exception_handler(Exception)
async def all_exception_handler(request, exc):
    return JSONResponse(
        status_code=500, content={"message": request.url.path + " " + str(exc)}
    )


########### DO NOT MODIFY ABOVE THIS LINE ###########


@app.get("/ping")
def ping():
    """
    Health check endpoint
    """
    return {"ping": "pong!"}


@app.post("/createaccount", response_model=schemas.Account)
def create_account(
    user: schemas.AccountCreate
):
    """
    Create a new account
    """
    return crud.create_account(user)

@app.post("subscribe")
def create_subscription():
    pass

@app.patch("/user/{user_id}", response_model = schemas.Account)
def update_user(
    user_id: int,
    update_data: schemas.AccountUpdate
):
    user = crud.get_account(user_id)
    return crud.update_account(user_id, update_data)