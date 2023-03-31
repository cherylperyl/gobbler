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
from datetime import datetime

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


########### HELPER FUNCTIONS ###########
def add_image_file_to_query(image_file, query):
    """
    Add image file to query.
    """

    operations = {"query": query, "variables": {"image_file": None}}
    map = {"image_file": ["variables.image_file"]}
    files = {"image_file": image_file.file}

    data = {
        "operations": json.dumps(operations),
        "map": json.dumps(map)
    }

    return files, data


def get_reservation_status(user_id, post_id):
    """
    Gets the reservation status of a post for a user. True if the user
    has reserved the post, False otherwise.
    """

    global reservation_ms_url

    if user_id == 0:  # case when user is not logged in
        return False
    else:
        url = f"{reservation_ms_url}/user/{user_id}/post/{post_id}"
        reservation = requests.get(url)
        if reservation.status_code == 404:
            return False
        else:
            return True


def calculate_available_reservations(post):
    """
    Calculates the number of available reservations for a post.
    """
    global reservation_ms_url

    if post["is_available"]:
        url = f"{reservation_ms_url}/post/slots/{post['post_id']}"
        reservation_count = requests.get(url)
        if reservation_count.status_code == 404:
            reservation_count = 0
        else:
            reservation_count = reservation_count.json()

        return post["total_reservations"] - reservation_count

    else:
        return 0

#######################################


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
                        post_desc: "{post.post_desc}",
                        user_id: {post.user_id},
                        image_file: $image_file,
                        file_name: "{image_file.filename}",
                        location_latitude: {post.location_latitude},
                        location_longitude: {post.location_longitude},
                        total_reservations: {post.total_reservations},
                        time_end: "{post.time_end}"
                    }}) {{
                        post_id,
                        title,
                        post_desc,
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

    files, data = add_image_file_to_query(image_file, query)

    r = requests.post(post_ms_url, files=files, data=data).json()

    if not r["data"]:
        print(r["errors"])
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
    reserved the post. If not logged in, use user_id = 0.
    """
    query = f"""
                query {{
                    post(post_id: {post_id}) {{
                        post_id,
                        title,
                        post_desc,
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
    r = requests.get(post_ms_url, params=payload).json()

    if not r["data"]:
        print(r["errors"])
        return JSONResponse(
            status_code=422, content={"error": "Retrieve of post failed."}
        )

    else:
        print("Posts successfully retrieved from Post MS.")
        post = r["data"]["post"]
        post["reserved"] = get_reservation_status(user_id, post_id)
        post["available_reservations"] = calculate_available_reservations(post)
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
    order of distance. If not logged in, pass in user_id = 0.
    """
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
                        total_reservations,
                        time_end,
                        created_at,
                        updated_at,
                        is_available
                    }}
                }}
            """
    payload = {"query": query}
    r = requests.get(post_ms_url, params=payload).json()

    if not r["data"]:
        print(r["errors"])
        return JSONResponse(
            status_code=422, content={"error": "Retrieve of nearby posts failed."}
        )

    else:
        nearby_posts = r["data"]["nearby_posts"]
        post_ids = [post["post_id"] for post in nearby_posts]

        url = f"{reservation_ms_url}/posts/slots"
        reservation_counts = requests.get(url, json=post_ids).json()

        url = f"{reservation_ms_url}/user/{user_id}"
        reservations = requests.get(url)
        if reservations.status_code == 404:
            reservations = []
        else:
            reservations = reservations.json()

        reserved_post_ids = {post["post_id"] for post in reservations}

        for i in range(len(nearby_posts)):
            if nearby_posts[i]["post_id"] in reserved_post_ids:
                nearby_posts[i]["reserved"] = True
            else:
                nearby_posts[i]["reserved"] = False

            nearby_posts[i]["available_reservations"] = nearby_posts[i]["total_reservations"] - reservation_counts[i]

            if nearby_posts[i]["available_reservations"] == 0:
                nearby_posts[i]["is_available"] = False

        return nearby_posts


@app.get("/createdpost", response_model=List[schemas.Post], tags=["Post"])
def created_posts(
    user_id: int
):
    """
    Gets all posts created by user_id. An empty list returned indicates that
    the user has not created any posts.
    """
    query = f"""query {{
                    posts_by_user(user_id: {user_id}){{
                        post_id,
                        title,
                        post_desc,
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
    r = requests.get(post_ms_url, params=payload).json()

    if not r["data"]:
        print(r["errors"])
        return JSONResponse(
            status_code=422, content={"error": "Retrieve of created posts failed."}
        )

    else:
        created_posts = r["data"]["posts_by_user"]
        post_ids = [post["post_id"] for post in created_posts]

        url = f"{reservation_ms_url}/posts/slots"
        reservation_counts = requests.get(url, json=post_ids).json()

        for i in range(len(created_posts)):
            created_posts[i]["available_reservations"] = created_posts[i]["total_reservations"] - reservation_counts[i]

            if created_posts[i]["available_reservations"] == 0:
                created_posts[i]["is_available"] = False

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
    # 1. get post details
    query = f"""query {{
                    post(post_id: {post_id}){{
                        post_id,
                        title,
                        post_desc,
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
    r = requests.get(post_ms_url, params=payload).json()

    if not r["data"]:
        print(r["errors"])
        return JSONResponse(
            status_code=422, content={"error": "Retrieve of created post failed."}
        )

    else:
        post = r["data"]["post"]
        post["users"] = []

        # 2. get reservations for the post
        url = f"{reservation_ms_url}/post/{post['post_id']}"
        reservations = requests.get(url)
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
        if post["is_available"]:
            post["available_reservations"] = post["total_reservations"] - reservation_count
        else:
            post["available_reservations"] = 0

        # 5. update post details
        if post["available_reservations"] == 0:
            post["is_available"] = False

        return post


@app.post("/updatepost", response_model=schemas.Post, tags=["Post"])
def update_post(
    post_id: int,
    post: schemas.PostUpdate = FormDepends(schemas.PostUpdate),
    image_file: UploadFile = File(None)
):
    """
    Attributes that can be updated: image, title, post_desc, location_latitude,
    location_longitude, total_reservations, time_end, is_available
    """

    post_query = "{"
    for key, value in post.dict().items():
        if value is not None:
            if key == "is_available":
                value = str(value).lower()

            if key == "image_file":
                value = "$image_file"
                post_query += f"file_name: \"{image_file.filename}\", "

            if (type(value) == str or type(value) == datetime) and value != "$image_file":
                post_query += f"{key}: \"{value}\", "
            else:
                post_query += f"{key}: {value}, "

    post_query = post_query[:-2] + "}"
    to_return = """{
                    post_id,
                    title,
                    post_desc,
                    user_id,
                    image_url,
                    location_latitude,
                    location_longitude,
                    total_reservations,
                    time_end,
                    created_at,
                    updated_at,
                    is_available
                }"""

    if image_file is None:
        query = f"""
                    mutation {{
                        update_post(post_id: {post_id},
                            post: {post_query}
                        ){to_return}
                    }}
                """

        payload = {"query": query}
        r = requests.post(post_ms_url, json=payload).json()
    else:
        query = f"""
                    mutation ($image_file: Upload!){{
                        update_post(post_id: {post_id},
                            post: {post_query}
                        ){to_return}
                    }}
                """
        files, data = add_image_file_to_query(image_file, query)
        r = requests.post(post_ms_url, files=files, data=data).json()

    if not r["data"]:
        print(r["errors"])
        return JSONResponse(
            status_code=422, content={"error": "Update of post failed."}
        )

    else:
        print("Update of post successful.")
        updated_post = r["data"]["update_post"]
        updated_post["available_reservations"] = calculate_available_reservations(updated_post)
        if updated_post["available_reservations"] == 0:
            updated_post["is_available"] = False

        return updated_post


@app.delete("/deletepost", response_model=schemas.Post, tags=["Post"])
def delete_post(
    post_id: int
):
    """
    Delete a post by post_id.
    """

    query = f"""
                mutation {{
                    delete_post(post_id: {post_id}){{
                        post_id,
                        title,
                        post_desc,
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
    r = requests.post(post_ms_url, json=payload).json()

    if not r["data"]:
        print(r["errors"])
        return JSONResponse(
            status_code=422, content={"error": "Delete of post failed."}
        )

    else:
        print("Delete of post successful.")
        return r["data"]["delete_post"]
