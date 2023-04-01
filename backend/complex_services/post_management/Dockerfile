FROM python:3.9-alpine

WORKDIR /code

COPY ./requirements.txt /code/requirements.txt

RUN apk add --no-cache --virtual .build-deps mariadb-dev build-base python3-dev

RUN pip install --upgrade -r /code/requirements.txt

COPY ./app /code/app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
