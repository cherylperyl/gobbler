# User Microservice
Stores user data. See [Database Schema](#database-schema) to see what details are stored.
___
## To run
`docker compose up`

Use browser to access http://localhost:8081/swagger/index.html to view and test the available endpoints.

## Todos
- put this on a server
- compare with chok to see what other features needs to be added/changed

## Database Schema
| Variable Name    | Type     |
|------------------|----------|
| userId           | int      |
| isPremium        | bool     |
| username         | string   |
| dateCreated      | DateTime |
| lastUpdated      | DateTime |
| creditCardNumber | string   |
| email            | string   |

## Endpoints
[GET] `/api/User` Get all users  
[POST] `/api/User` Add new user  
[PUT] `/api/User` Update user details by user_id  
[GET] `/api/User/{user_id}` Get user by user_id  
[DELETE] `/api/User/{user_id}` Delete user by user_id  
[GET] `/api/User/by_email/{email}` Get user by email


