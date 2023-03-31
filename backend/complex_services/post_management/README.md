# Post Management

Manages anything related to posts.
___

## To run

1. Go to the `backend/` directory and run `docker compose up --build`
2. Use browser to access http://localhost:8084/docs to view and test the [available endpoints](#endpoints).  
3. Run `test.py` to see the consumption output from New Post queue.
4. To shut down: `docker compose down` in the same `backend/` directory.

## Todos

- get a list of posts that a user has created - userId -> List of posts
- change get available slots api --> wait for esther to update the reservation service endpoint

## Endpoints

[POST] `/createpost`

- Creates a new post
- Publish post to New Post queue for consumption by Notification Service

[GET] `/viewposts`

- Gets all posts within a 2.5km radius of the user's location.
- Calculate available reservations left with help from reservation MS.

[GET] `/createdposts/{user_id}`

- Gets all posts created by the user_id.
- Calculate available reservations left with help from reservation MS.
