FROM python:3.9

WORKDIR /code

COPY ./requirements.txt /code/requirements.txt

RUN pip install --upgrade -r /code/requirements.txt

RUN apt-get update && apt-get install -y redis-server
COPY redis.conf /etc/redis/redis.conf

COPY ./app /code/app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
