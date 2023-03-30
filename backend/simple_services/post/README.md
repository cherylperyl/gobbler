# Post Microservice
GraphQL service

## To Use

```bash
docker compose up --build
```

Make all queries to at http://localhost:5001/graphql/

### Create a Post with an image file (inside `/backend/test.png`)
```bash
curl -X POST \
-H "Authorization: Bearer <ACCESS_TOKEN>" \
-H "Content-Type: multipart/form-data" \
-F operations='{ "query": "mutation create_post($postInput: PostInput!) { create_post(post: $postInput) { post_id title } }", "variables": { "postInput": { "user_id": 123, "title": "Sample Post", "location_latitude": 37.7749, "location_longitude": -122.4194, "available_reservations": 2, "total_reservations": 5, "time_end": "2023-03-20T18:00:00", "image_file": null, "file_name": "test.png" } } }' \
-F map='{ "0": ["variables.postInput.image_file"] }' \
-F 0=@test.png \
http://localhost:8082/graphql
```
