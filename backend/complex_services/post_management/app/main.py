from typing import List

from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import JSONResponse
from . import schemas, amqp_setup
import requests
import pika
import json
import os
from pyfa_converter import FormDepends
from dotenv import load_dotenv

load_dotenv()

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
USER_MS_SERVER = os.getenv("USER_MS_SERVER")
USER_MS_PORT = os.getenv("USER_MS_PORT")

post_ms_url = "http://" + POST_MS_SERVER + ":" + POST_MS_PORT + "/graphql"
reservation_ms_url = "http://" + RESERVATION_MS_SERVER + ":" + RESERVATION_MS_PORT + "/reservations"
user_ms_url = "http://" + USER_MS_SERVER + ":" + USER_MS_PORT + "/api/User"

sample_post = {
    "title": "Sample Post",
    "user_id": 1,
    "image_url": "https://picsum.photos/id/237/200/300",
    "location_latitude": 1.0,
    "location_longitude": 1.0,
    "available_reservations": 1,
    "total_reservations": 1,
    "time_end": "2030-05-01T00:00:00"
}

# catch all post ms errors and return error message
@app.exception_handler(requests.exceptions.ConnectionError)
async def post_ms_exception_handler(request, exc):
    return JSONResponse(
        status_code=500, content={"message": "Post microservice is down."}
    )

@app.get("/ping", tags=["Health Check"])
def ping():
    """
    Health check endpoint
    """
    return {"ping": "pong!"}


@app.post("/createpost", response_model=schemas.Post, tags=["Post"])
def create_post(
    post: schemas.PostCreate = FormDepends(schemas.PostCreate),
    image_file: UploadFile = File(...)
):
    """
    Create a new post.
    """
    # create post with post microservice
    query = f"""
                mutation ($image_file: Upload!){{
                    create_post(post: {{
                        title: "{post.title}",
                        user_id: {post.user_id},
                        image_file: $image_file,
                        file_name: "{image_file.filename}",
                        location_latitude: {post.location_latitude},
                        location_longitude: {post.location_longitude},
                        available_reservations: {post.total_reservations},
                        total_reservations: {post.total_reservations}
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

    operations = {"query": query, "variables": {"image_file": None}}
    map = {"image_file": ["variables.image_file"]}
    files = {"image_file": image_file.file}

    r = requests.post(post_ms_url, files=files, data={
        "operations": json.dumps(operations),
        "map": json.dumps(map)
    }).json()

    if not r["data"]:

        # log errors from post ms
        print(r["errors"])

        # return error response
        return JSONResponse(
            status_code=422, content={"error": "Post creation failed."}
        )

    else:
        print("Post successfully created in Post MS.")
        created_post = r["data"]["create_post"]

        # publish post to rabbitmq
        channel.basic_publish(
            exchange=amqp_setup.exchangename,
            routing_key="newpost",
            body=json.dumps(created_post),
            properties=pika.BasicProperties(delivery_mode=2)
        )  # delivery_mode=2 make message persistent within the matching queues until it is received by some receiver

        post_id = created_post["post_id"]
        print(f"Sent new post (post id: {post_id}) to RabbitMQ")

    return created_post


@app.get("/viewpost", response_model=schemas.PostUserView, tags=["Post"])
def view_post(
    post_id: int,
    user_id: int
):
    """
    Gets a post by its ID for a user. Will indicate if the user has already
    reserved the post.
    """
    # 1. get post with post microservice
    query = f"""
                query {{
                    post(post_id: {post_id}) {{
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
    post = r.json()["data"]["post"]

    # 2. get reservation for post
    url = f"{reservation_ms_url}/user/{str(user_id)}/post/{str(post_id)}/"
    reservation = requests.get(url)
    if reservation.status_code == 404:
        post["reserved"] = False
    else:
        post["reserved"] = True

    # 3. get number of reservations for post
    url = f"{reservation_ms_url}/post/slots/"
    reservation_count = requests.get(url + str(post["post_id"]))
    if reservation_count.status_code == 404:
        reservation_count = 0
    else:
        reservation_count = reservation_count.json()

    post["available_reservations"] = post["total_reservations"] - reservation_count

    # 4. update post details
    if post["available_reservations"] == 0:
        post["is_available"] = False

    return post


@app.get("/viewposts", response_model=List[schemas.NearbyPost], tags=["Post"])
def view_posts(
    latitude: float,
    longitude: float,
    user_id: int
):
    """
    Gets all posts within a 5km radius of the user's location in ascending
    order of distance.
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
                        distance,
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
    r = requests.get(post_ms_url, params=payload)
    nearby_posts = r.json()["data"]["nearby_posts"]

    url1 = f"{reservation_ms_url}/post/slots/"
    url2 = f"{reservation_ms_url}/user/{user_id}/post/"
    for post in nearby_posts:

        # 2. get number of reservations for each post
        reservation_count = requests.get(url1 + str(post["post_id"]))
        if reservation_count.status_code == 404:
            reservation_count = 0
        else:
            reservation_count = reservation_count.json()

        # 3. check if user has reserved the post
        reservation = requests.get(url2 + str(post["post_id"]))
        if reservation.status_code == 404:
            post["reserved"] = False
        else:
            post["reserved"] = True

        # 4. calculate available reservations based on total and reserved
        post["available_reservations"] = post["total_reservations"] - reservation_count

        # 5. update post details
        if post["available_reservations"] == 0:
            post["is_available"] = False

    return nearby_posts


@app.get("/createdpost", response_model=List[schemas.Post], tags=["Post"])
def created_posts(
    user_id: int
):
    """
    Gets all posts created by user_id. An empty list returned indicates that the user has not created any posts.
    """

    # 1. get posts created by user
    query = f"""query {{
                    posts_by_user(user_id: {user_id}){{
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
            }}"""

    payload = {"query": query}
    r = requests.get(post_ms_url, params=payload)
    created_posts = r.json()["data"]["posts_by_user"]

    # 2. get number of reservations left for each post
    url = f"{reservation_ms_url}/post/slots/"
    for post in created_posts:
        reservation_count = requests.get(url + str(post["post_id"]))
        if reservation_count.status_code == 404:
            reservation_count = 0
        else:
            reservation_count = reservation_count.json()

        # 3. calculate available reservations based on total and reserved
        post["available_reservations"] = post["total_reservations"] - reservation_count

        # 4. update post details
        if post["available_reservations"] == 0:
            post["is_available"] = False

    return created_posts


@app.get("/viewcreatedpost", response_model=schemas.CreatedPost, tags=["Post"])
def view_created_post(
    post_id: int
):
    """
    Get details of a post created by a poster by post_id.
    Includes the most updated reservation count as well as the list of users
    that have reserved the post. Reservations by non-existent users are not
    included.
    """

    # 1. get post
    query = f"""query {{
                    post(post_id: {post_id}){{
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
            }}"""

    payload = {"query": query}
    r = requests.get(post_ms_url, params=payload)
    post = r.json()["data"]["post"]
    post["users"] = []

    # 2. get reservations for the post
    url = f"{reservation_ms_url}/post/"
    reservations = requests.get(url + str(post["post_id"]))
    if reservations.status_code == 404:
        reservation_count = 0

    # 3. get users that have reserved the post
    else:
        url = f"{user_ms_url}/"
        for reservation in reservations.json():
            user = requests.get(url + str(reservation["user_id"]))
            if user.status_code != 400:
                post["users"].append(user.json())
        reservation_count = len(post["users"])

    # 4. calculate available reservations based on total and reserved
    post["available_reservations"] = post["total_reservations"] - reservation_count

    # 4. update post details
    if post["available_reservations"] == 0:
        post["is_available"] = False

    return post


@app.post("/updatepost", response_model=schemas.Post, tags=["Post"])
def update_post_availability(
    post_id: int,
    is_available: bool
):
    """
    Updates a post's availability status.
    """

    # 1. update post with post microservice
    query = f"""
                mutation {{
                    update_post(post_id: {post_id},
                        post: {{
                            is_available: {str(is_available).lower()}
                        }}
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
    r = requests.post(post_ms_url, json=payload)
    updated_post = r.json()["data"]["update_post"]

    if not updated_post["is_available"]:
        updated_post["available_reservations"] = 0

    else:
        # 2. get number of reservations for post
        url = f"{reservation_ms_url}/post/slots/"
        reservation_count = requests.get(url + str(post_id))
        if reservation_count.status_code == 404:
            reservation_count = 0
        else:
            reservation_count = reservation_count.json()

        # 3. calculate available reservations based on total and reserved
        updated_post["available_reservations"] = updated_post["total_reservations"] - reservation_count

    return updated_post
