# Table of Contents

1. [Setting up Stripe](#setting-up-stripe)
2. [Setting up Gobbler with Docker](#setting-up-gobbler-with-docker)

# Introduction

Our backend architecture is organised into a three layer service-oriented architecture (API gateway, complex microservice, simple microservice). They are deployed as Docker containers and can be orchestrated using either `Docker Compose` or `Kubernetes`.

## Features

OS-independent backend designed to support the Gobbler mobile application. Services are contained within the same internal network and exposed via a Kong API Gateway.

### API Gateway

We use Kong as our API Gateway in a db-less mode and configured declaratively.
The service is hosted and reachable at http://gobbler.world.

##### Main Endpoints

We configured the following routings within Kong:

- `/user` - Directs traffic to the User Management service
- `/post` - Directs traffic to the Post Management service
- `/reservation` - Directs traffic to the Reservation Management service

##### Plugins

We added the following plugins that is applied to each request going through Kong:

- `rate-limit` - Global rate limit of 100 requests/min to prevent users from impacting the services with abnormal usage
- `authentication_plugin` - Custom authentication plugin that routes all requests (except public endpoints) to our Authentication Service to authenticate and authorise access via JWT tokens

### Complex Microservices

We have several complex microservices that mainly orchestrate business logic, with some elements of choreography for notification events.

- `User Management` - `Python FastAPI` based, handles all user related logic
- `Post Management` - `Python FastAPI` based, handles all post related logic
- `Reservation Management` - `Python FastAPI` based, handles all reservation related logic
- `Notification Management` - `Typescript Koa` based, handles all notification events

##### Complex Features

- Notifications - `Post Management` and `Reservation Management` triggers notification events (new post for premium users, update/delete post) which are offloaded via a RabbitMQ queue to be choreographed by `Notification Management`.
- Race condition - `Reservation Management` uses Redis locks to prevent race conditions between users reserving a post across a distributed system.

### Simple Microservices

We isolate persistant storage access to atomic microservices to ensure data consistency.

- `User Service` - `C# .NET` based, handles all user information
- `Post Service` - `Python FastAPI GraphQL` based, handles all post information
- `Payment Service` - `Python FastAPI` based, handles all payment and subscription with Stripe
- `Reservation Service` - `Python FastAPI` based, handles all reservation information
- `Authentication Service` - `Java Spring Boot` based, handles all authentication and authorisation mechanisms

Each of these maintain communication with their respective databases. We opt between `MySQL` and `PostgreSQL` databases depending on the support and connectivity provided by each service (which can defer based on language and frameworks).

# Prerequisites

- Recommended platform - MacOS Monterey 12.4 Intel, Debian Version 11
- Docker installed
  - Kubectl optional

### Verify Docker

Run `docker` in terminal to check if Docker is installed. An example of a positive response:

```bash
$ docker
Usage:  docker [OPTIONS] COMMAND

A self-sufficient runtime for containers

Options:
...
```

If `Command 'docker' not found...`, proceed with installing Docker

### Install Docker

Refer to https://docs.docker.com/desktop/install/mac-install/ for instructions.

# Installation and set-up

### Set-up local directories

Assuming that you have cloned this repository and navigated to the root of the project, navigate to this folder (`/backend`)

> e.g. if project root path is `/usr/lib/gobbler`

```bash
cd /usr/lib/gobbler/backend
```

### Provide secrets

We require several secrets across each of our services.
Make a copy of `.env.example`, rename it to `.env` and provide the information as stated using any text editor (`vi .env.example`).

1. `cp .env.example .env`
2. Replace `<>` fields with the respective information (subdomain, email_address, API_key).

**Note: `.env` is automatically ignored by git**

```yaml
AUTH_TOKEN_SECRET=your_secret
DATABASE_USER=your_username
DATABASE_PASSWORD=your_password
GCP_PROJECT_ID=your_project_id
STRIPE_API_KEY=your_stripe_api_key
```

### Configure gcloud credentials

We require gcloud credentials in order for our `Post Service` to upload image files to Google Cloud Storage. This can be either be done by:

1. Setting up gcloud authentication locally OR
2. Supplying `application_default_credentials.json`

##### Setting up gcloud authentication locally

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

A successful login will automatically populate the credentials at `~/.config/gcloud/application_default_credentials.json`.

##### Supplying `application_default_credentials.json`

Alternatively, you may choose to skip installing the `gcloud` cli package and load the credentials directly. Simply load a valid `application_default_credentials.json` file in the `~/.config/gcloud` directory. You may need to create folders as needed.

### Configure Firebase credentials

We also require Firebase service account credentials in order for our `Notification Management` service to trigger push notifications. Similarly, this can either be done by:

1. Download a Firebase service account OR
2. Populate the JSON structure of the service account

##### Download a Firebase service account

Using a valid Firebase account, you can retrieve the service account credentials following: https://firebase.google.com/docs/admin/setup#initialize_the_sdk_in_non-google_environments and place it in `complex_services/notification_management/service-account.json`.

##### Populate the JSON structure of the service account

Alternatively, you may choose to make a copy of [service-account.json.example](complex_services/notification_management/service-account.json.example), rename it to `service-account.json` and manually populate the fields.

# Deploying the backend

The deployment can be executed through either of two methods:

1. Through Docker Compose
2. Through Kubernetes

### Through Docker Compose

Deploying using Docker Compose relies on the `docker-compose.yml` file for the container specifications and runtime configurations. Environment variables in the `.env` created earlier will be loaded automatically (as long as the commands are run in the same folder as the `.env` file).

1. Run the following command to rebuild the Docker images:

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

   or if the containers are already running.

   ```bash
   # windows
   docker-compose up --build

   # macOS
   docker compose up --build
   ```

   or if you want to pull the latest images from Artifact Registry (requires gcloud authentication)

   ```bash
   # windows
   docker-compose pull

   # macOS
   docker compose pull
   ```

2. Run the following command to run the containers:

   ```bash
   # windows
   docker-compose up

   # macOS
   docker compose up
   ```

> Note: Individual services are accessible via port forwarding in the current Docker Compose configuration. This is just to aid in debugging and review purposes. The actual app deployment should not have any port forwarding except for Kong.

### Through Kubernetes

Kubernetes deployment depends on Kubernetes manifests found in the `./kubernetes` folder. We use a combination of deployment, service, and network manifests to deploy the services in an internal network with Kong acting as an external load balancer. While we have semi-tailored certain specifications to Google Kubernetes Engine (GKE), the open-source nature of Kubernetes allows us to virtually deploy these manifests on any Kubernetes cloud provider (e.g. AWS, Azure, DigitalOcean).

##### Connecting to GKE

Assuming that the `gcloud` cli tool is installed and logged in, install `kubectl`.

```bash
gcloud components install kubectl
```

Install GKE authentication plugin and verify the installation.

```bash
# install
gcloud components install gke-gcloud-auth-plugin

# verify
gke-gcloud-auth-plugin --version
```

Create a GKE cluster (`gobbler`), use the `GCP_PROJECT_ID` environment variable if available

```bash
gcloud container clusters create-auto gobbler \
    --region asia-southeast1 \
    --project=${GCP_PROJECT_ID}
```

Load GKE cluster credentials and verify credentials.

```bash
gcloud container clusters get-credentials gobbler \
    --region=asia-southeast1

# verify
kubectl get namespaces

# expected output
NAME              STATUS   AGE
default           Active   51d
kube-node-lease   Active   51d
kube-public       Active   51d
kube-system       Active   51d
```

##### Loading Kubernetes secrets

Unlike Docker Compose, Kubernetes does not use `.env` files but instead use Kubernetes secret. Run the following commands to add the secrets into the cluster.

```bash
# creates .env file secrets
kubectl create secret generic gobbler --from-env-file=.env

# creates GCP application default credentials secret
kubectl create secret generic gobbler-gcp --from-file=key.json=~/.config/gcloud/application_default_credentials.json

# creates Firebase service account secret
kubectl create secret generic gobbler-firebase --from-file=service-account.json=complex_services/notification_management/service-account.json
```

##### Deploy Kubernetes manifests

> Note: The Kubernetes manifests' images contain a placeholder string ${GCP_PROJECT_ID} which needs to be substituted with the actual GCP Project ID. This issue is automated in the script deploy below

```bash
kubectl apply -R -f ./kubernetes
```

##### Script Deploy

We provided several scripts to automate the deployment process, since the `GCP_PROJECT_ID` is a variable field that needs to be adjusted on the manifests before deploying.

> Note: The following commands are written for a Linux environment and depends on the command `sed` to apply the string manipulation. Mac variations are provided as well with a `-mac` suffix that depends on the brew package `gsed`.

In the `backend` folder, you can run:

```bash
# Build and push containers (based on Docker Compose), then deploy the manifests on Kubernetes
./scripts/build-and-deploy-kube.sh

# Deploy Kubernetes manifest only
./scripts/deploy-kube.sh

# Revert string manipulation (injection of GCP_PROJECT_ID)
./scripts/revert.sh
```
