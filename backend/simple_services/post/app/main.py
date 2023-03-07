from fastapi import FastAPI

from app import models
from app.database import engine
from app.query_schema import Query
from app.mutation_schema import Mutation

from fastapi.responses import JSONResponse

import strawberry
from strawberry.schema.config import StrawberryConfig
from strawberry.fastapi import GraphQLRouter


########### DO NOT MODIFY BELOW THIS LINE ###########
# create tables
models.Base.metadata.create_all(bind=engine)

# create FastAPI app
app = FastAPI()

# catch all exceptions and return error message
@app.exception_handler(Exception)
async def all_exception_handler(request, exc):
    return JSONResponse(
        status_code=500, content={"message": request.url.path + " " + str(exc)}
    )

########### DO NOT MODIFY ABOVE THIS LINE ###########

schema = strawberry.Schema(query=Query,mutation=Mutation,config=StrawberryConfig(auto_camel_case=False))

graphql_app = GraphQLRouter(schema)

app.include_router(graphql_app, prefix='/graphql')