from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy.orm import Session

import models
from database import engine
from query_schema import Query
from mutation_schema import Mutation

from fastapi.responses import JSONResponse

import strawberry
from strawberry.schema.config import StrawberryConfig
from strawberry.fastapi import GraphQLRouter


########### DO NOT MODIFY BELOW THIS LINE ###########
# create tables
models.Base.metadata.create_all(bind=engine)

# create FastAPI app
# app = FastAPI()


# catch all exceptions and return error message
# @app.exception_handler(Exception)
# async def all_exception_handler(request, exc):
#     return JSONResponse(
#         status_code=500, content={"message": request.url.path + " " + str(exc)}
#     )

########### DO NOT MODIFY ABOVE THIS LINE ###########

schema = strawberry.Schema(query=Query,mutation=Mutation,config=StrawberryConfig(auto_camel_case=False))

graphql_app = GraphQLRouter(schema)

app = FastAPI()
app.include_router(graphql_app, prefix='/graphql')


# @app.get("/ping")
# def ping():
#     """
#     Health check endpoint
#     """
#     return {"ping": "pong!"}


# @app.get("/posts/all", response_model=List[schemas.Post])
# def get_all_posts(db: Session = Depends(get_db)):
#     """
#     Get all posts
#     """
#     posts = crud.get_all(db)
#     if not posts:
#         raise HTTPException(status_code=404, detail="No reservations found")
#     return posts


# @app.get("/reservations/{reservation_id}", response_model=schemas.Post)
# def get_reservation_by_reservation_id(
#     reservation_id: int, db: Session = Depends(get_db)
# ):
#     """
#     Get reservation by reservation_id
#     """
#     db_reservation = crud.get_reservation_by_reservation_id(reservation_id, db)
#     if db_reservation is None:
#         raise HTTPException(status_code=404, detail="Reservation not found")
#     return db_reservation


# @app.get("/posts/{post_id}", response_model=List[schemas.Post])
# def get_post_by_post_id(post_id: int, db: Session = Depends(get_db)):
#     """
#     Get post by post_id
#     """
#     post = crud.get_post_by_post_id(post_id, db)
#     if not post:
#         raise HTTPException(status_code=404, detail="No reservations found")
#     return post


# @app.post("/posts", response_model=schemas.Post)
# def create_post(
#     post: schemas.PostCreate, db: Session = Depends(get_db)
# ):
#     """
#     Create a new post
#     """
#     db_post = crud.create_post(post, db)
#     return db_post


# @app.put("/posts/{post_id}", response_model=schemas.Post)
# def update_post(
#     post_id: int,
#     post: schemas.PostUpdate,
#     db: Session = Depends(get_db),
# ):
#     """
#     Update a post
#     """
#     db_post = crud.get_post_by_post_id(post_id, db)
#     if db_post is None:
#         raise HTTPException(status_code=404, detail="Post not found")
#     return crud.update_post(db, db_post, post)


# @app.delete("/posts/{post_id}", response_model=schemas.Post)
# def delete_posts(post_id: int, db: Session = Depends(get_db)):
#     """
#     Delete a post
#     """
#     db_post = crud.get_post_by_post_id(post_id, db)
#     if db_post is None:
#         raise HTTPException(status_code=404, detail="Post not found")
#     deleted_post = crud.delete_reservation(db, db_post)
#     return deleted_post


