# FastAPI Template

This is a template setup for FastAPI, adapted from Jon's FYP project. It's not golden standard in terms of code organisation but it's simpler to understand and maintain

## To Use

Make a copy of this whole folder into `/backend` and rename it to your intended service name

## How to Navigate

All application code should go inside `/app`

### `/app/__init__.py`

This file makes the app folder a module, therefore you can do thinggs like `from app import ...`.
**Don't need to edit**

### `/app/crud.py`

This file defines the CRUD functions for interacting with the database.
**Edit as need be**

Typically, one GET ALL, one GET ONE, one CREATE, one UPDATE, and one DELETE is sufficient. You can also skip the DELETE if not necessary.

### `/app/database.py`

This file configures the database connection.
**Should not need to edit unless swapping out databases**

Currently, postgres and mysql URIs are available. **Delete the one not in use**.

Relies on environment variables to build connection URI.

### `/app/main.py`

Entrypoint for FastAPI application.
This file also contains all the endpoints.
**Edit as need be, but careful not to break the top area that is denoted by do not edit**

Inside here, theres a `ping` endpoint. **PLEASE DO NOT REMOVE**. This is so we can health check our services.

### `/app/models.py`

This file contains the SQLAlchemy model class that is used to interact with the database. It is crucial to ensure that the attributes are aligned with the table definition.
**Edit as need be**

### `/app/schemas.py`

This file contains the Pydantic model class that is used to type validate the objects used in endpoints, and in translation to SQLAlchemy models. This should mimic the SQLAlchemy model class, although there is a separate of attributes depending on the usage (CREATE, UPDATE, etc.) so as to allow things like optional values.
**Edit as need be**

### `/.env.example`

Make a copy of this file and rename it `/.env`. Populate as necessary. This is the secure store of environment variables.
**NEVER COMMIT ENVIRONMENT VARIABLES**. If you happen to accidentally commit, immediately ping the group so someone with know how can try to wipe it from git history.

### `/Dockerfile`

This file contains Dockerfile definitions.
**Edit as need be**
Please update the CMD port and make sure there's no clash.

Note: Avoid using any alpine docker images because things like SQL wheels are missing and a pain to fix. If you don't know what's alpine, it's fine.

### `/requirements.txt`

This file contains all the Python dependencies.
**Please update with new packages**

## How to run

#### As Python executable (for Development)

```bash
uvicorn app.main:app --reload
```

You can visit the url `/docs` to view the OpenAPI spec and play with the endpoints (who needs Postman lol)

```bash
http://127.0.0.1:8000/docs
```

#### As docker container

```bash
docker build -t service_name .

docker run \
-e PYTHONPATH=$PYTHONPATH \
-e DB_SERVER=$DB_SERVER \
-e DB_PORT=$DB_PORT \
-e DB_USER=$DB_USER \
-e DB_PASSWORD=$DB_PASSWORD \
-e DATABASE=$DATABASE \
-p 5001:5001 service_name
```
