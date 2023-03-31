# Table of Contents
1. [Setting up Stripe](#setting-up-stripe)
2. [Setting up Gobbler with Docker](#setting-up-gobbler-with-docker)


# Setting up Stripe
To test locally, download the [Stripe CLI](https://stripe.com/docs/stripe-cli) and set it to forward events to the app 

`stripe listen --forward-to localhost:5000/webhook`

You can then trigger Stripe events to simulate successful subscriptions 

`stripe trigger customer.subscription.created`

When deployed, a Stripe account will be set up to forward customer.subscription.created events to the deployed endpoint 


# Setting up Gobbler with Docker

### `/.env.example`

Make a copy of this file and rename it `/.env`. Populate as necessary. This is the secure store of environment variables.
**NEVER COMMIT ENVIRONMENT VARIABLES**. 

## Connecting to GCP

1. Install gcloud cli (https://cloud.google.com/sdk/docs/install)
```bash
# For Mac:
brew install --cask google-cloud-sdk
```

2. Login via gcloud CLI. This will prompt a browser to login a google account. Use the gobbler google account.
```bash
gcloud auth login
```

3. Create gcloud credential json.
```bash
gcloud auth application-default login
```

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

