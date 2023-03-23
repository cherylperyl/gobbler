# User complex MS

Calls user MS for account creation and update. 

## How to run
#### As Python executable (for Development)

```bash
uvicorn app.main:app --reload
```

You can visit the url `/docs` to view the OpenAPI spec and play with the endpoints 

```bash
http://127.0.0.1:8000/docs
```

#### As docker container

```bash
docker build -t user_complex_ms .

docker run \
-e USER_MS_SERVER [location of user ms server]
-e USER_MS_PORT [location of user ms port]
-p 5001:8000 user_complex_ms
```
