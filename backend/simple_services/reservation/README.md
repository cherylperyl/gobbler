# Reservation Microservice
Handles creating, deleting and retrieving of reservations across the app and for a single post. See [Database Schema](#database-schema) to see what details are stored.
___


## To run
`docker compose up` (in main folder)

Use browser to access http://localhost:5003/docs to view and test the available endpoints.


## Database Schema
| Variable Name   | Type     |
|-----------------|----------|
| reservation_id  | int      |
| user_id         | int      |
| post_id         | int      |
| created_at      | DateTime |
| updated_at      | DateTime |


## Endpoints
[GET] `/reservations/all` Get all reservations  
[GET] `/reservations/{reservation_id}` Get reservations by reservation_id
[GET] `/reservations/post/{post_id}` Get reservations by post_id
[GET] `/reservations/post/slots/{post_id}` Get number of reservations by post_id
[POST] `/reservations/` Create a new reservation
[PUT] `/reservations/{reservation_id}` Update a reservation
[DELETE] `/reservations/{reservation_id}` Delete reservation by reservation_id  