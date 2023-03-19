from typing import List

from fastapi import FastAPI
from fastapi.responses import JSONResponse
from . import schemas, amqp_setup
import requests
import pika
import json
import os


########### DO NOT MODIFY BELOW THIS LINE ###########
# create FastAPI app
app = FastAPI()

# set up AMQP
AMQP_SERVER = os.getenv("AMQP_SERVER")
AMQP_PORT = os.getenv("AMQP_PORT")
channel = amqp_setup.setup(AMQP_SERVER, AMQP_PORT)

# catch all exceptions and return error message
@app.exception_handler(Exception)
async def all_exception_handler(request, exc):
    return JSONResponse(
        status_code=500, content={"message": request.url.path + " " + str(exc)}
    )

########### DO NOT MODIFY ABOVE THIS LINE ###########

POST_MS_SERVER = os.getenv("POST_MS_SERVER")
POST_MS_PORT = os.getenv("POST_MS_PORT")
RESERVATION_MS_SERVER = os.getenv("RESERVATION_MS_SERVER")
RESERVATION_MS_PORT = os.getenv("RESERVATION_MS_PORT")

post_ms_url = "http://" + POST_MS_SERVER + ":" + POST_MS_PORT + "/graphql"
reservation_ms_url = "http://" + RESERVATION_MS_SERVER + ":" + RESERVATION_MS_PORT + "/reservations"

sample_post = {
    "title": "Sample Post",
    "user_id": 1,
    "image_url": "https://picsum.photos/id/237/200/300",
    "location_latitude": 1.0,
    "location_longitude": 1.0,
    "available_reservations": 1,
    "total_reservations": 1,
    "time_end": "2021-05-01T00:00:00"
}


@app.get("/ping", tags=["Health Check"])
def ping():
    """
    Health check endpoint
    """
    return {"ping": "pong!"}


@app.post("/createpost", response_model=schemas.Post, tags=["Post"])
def create_post(
    post: schemas.PostCreate
):
    """
    Create a new post.
    """

    # create post with post microservice
    query = f"""
                mutation {{
                    create_post(post: {{
                        title: "{post.title}",
                        user_id: {post.user_id},
                        image_url: "{post.image_url}",
                        location_latitude: {post.location_latitude},
                        location_longitude: {post.location_longitude},
                        available_reservations: {post.available_reservations},
                        total_reservations: {post.total_reservations},
                        time_end: "{post.time_end}"
                    }}) {{
                        post_id,
                        title,
                        user_id,
                        image_url,
                        location_latitude,
                        location_longitude,
                        available_reservations,
                        total_reservations,
                        time_end,
                        created_at,
                        updated_at,
                        is_available
                    }}
                }}
            """
    
    payload = {"query": query}
    r = requests.post(post_ms_url, json=payload)
    created_post = r.json()["data"]["create_post"]

    # publish post to rabbitmq
    channel.basic_publish(
        exchange=amqp_setup.exchangename,
        routing_key="newpost",
        body=json.dumps(created_post),
        properties=pika.BasicProperties(delivery_mode=2)
    )  # delivery_mode=2 make message persistent within the matching queues until it is received by some receiver

    return created_post


@app.get("/viewposts", response_model=List[schemas.Post], tags=["Post"])
def view_posts(
    latitude: float,
    longitude: float
):
    """
    Gets all posts within a 2.5km radius of the user's location.
    """

    # 1. get nearby posts with post microservice
    query = f"""
                query {{
                    nearby_posts(
                    lat:{latitude},
                    long:{longitude},
                    ){{
                        post_id,
                        title,
                        user_id,
                        image_url,
                        location_latitude,
                        location_longitude,
                        total_reservations,
                        time_end,
                        created_at,
                        updated_at,
                        is_available
                    }}
                }}
            """
    payload = {"query": query}
    r = requests.get(post_ms_url, params=payload)
    nearby_posts = r.json()["data"]["nearby_posts"]

    # 2. get number of reservations for each post
    url = f"{reservation_ms_url}/posts/slots/"
    for post in nearby_posts:
        reservation_count = requests.get(url + str(post["post_id"]))
        if reservation_count.status_code == 404:
            reservation_count = 0
            # calcaulate available reservations based on total and reserved
            post["available_reservations"] = post["total_reservations"] - reservation_count
        else:
            post["available_reservations"] = post["total_reservations"] - reservation_count.json()

    return nearby_posts


@app.get("/createdpost", response_model=List[schemas.Post], tags=["Post"])
def created_posts(
    user_id: int
):
    """
    Gets all posts created by user_id. An empty list returned indicates that the user has not created any posts.
    """

    # 1. get all posts
    query = """
                query {
                    posts{
                        post_id,
                        title,
                        user_id,
                        image_url,
                        location_latitude,
                        location_longitude,
                        total_reservations,
                        time_end,
                        created_at,
                        updated_at,
                        is_available
                    }
                }
            """
    payload = {"query": query}
    r = requests.get(post_ms_url, params=payload)
    posts = r.json()["data"]["posts"]

    # 2. filter posts by user_id
    created_posts = [post for post in posts if post["user_id"] == user_id]

    # 3. get number of reservations left for each post
    url = f"{reservation_ms_url}/posts/slots/"
    for post in created_posts:
        reservation_count = requests.get(url + str(post["post_id"]))
        if reservation_count.status_code == 404:
            reservation_count = 0
            post["available_reservations"] = post["total_reservations"] - reservation_count
        else:
            post["available_reservations"] = post["total_reservations"] - reservation_count.json()

    return created_posts
