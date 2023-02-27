### Rebuilding the Docker images

If you have made changes to the Dockerfile, requirements.txt, or any other files used to build the Docker images, you will need to rebuild the images before you can run the application.

1. Navigate to the directory containing the `docker-compose.yml` file.

2. Run the following command to rebuild the Docker images:
    ```bash
    # windows
    docker compose build

    # macOS
    docker compose build
    ```
    or if you want to rebuild the images without using the cache.
    ```bash
    # windows
    docker-compose build --no-cache

    # macOS
    docker compose build --no-cache
    ```
    if the containers are already running.
    ```bash
    # windows
    docker-compose up --build

    # macOS
    docker compose up --build
    ```

3. Run the following command to run the containers:
    ```bash
    # windows
    docker compose up

    # macOS
    docker-compose up
    ```
