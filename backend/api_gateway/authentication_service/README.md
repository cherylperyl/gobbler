# Authentication Service
## Prerequisites

- Recommended platform
  - Development: macOS Monterey (Intel)
  - Production: Linux (Ubuntu 16.04)
- [JDK 1.8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
- [Maven 3](https://maven.apache.org)

<p align="right">(<a href="#top">back to top</a>)</p>

## Installation and Set-Up

### Compile JAR file for Docker deployment

Ensure that you have `mvn` installed. Run the script:
```
./scripts/compile.sh
```

### Choosing the Environment to run
This application is created to be production ready. To streamline the setup for developers, a dev environment was setup to use H2, an in-memory database and seeding of test data. 

To run the application in production, a separate environment properties is created.

Instruction to choose which environment properties the application should run:
1. Open `src\main\java\resources\application.properties`
2. Update the attribute `spring.profiles.active` from  `dev` to `prod` for production mode and vice versa for development mode. 


### Provide Environment Variables

This application relies on Mail Credentials, Web Server URL and Authentication Secrets to assist in computation logic and data. We need to provide it the following information. Edit the different variables in `.env.example` using any text editor (`vi .env.example`).

1. Navigate to application root
```bash
cd cpa
```
2. Replace `<>` fields with the respective information
3. Rename `.env.dev.example` to `.env` for running in development mode
4. Rename `.env.prod.example` to `.env` for running in Production mode

**Note: `.env` is automatically ignored by git`**

<p align="right">(<a href="#top">back to top</a>)</p>

## Running the Application Locally

There are several ways to run a Spring Boot application on your local machine. One way is to execute the `main` method in the `cpa.src.main.java.com.gobbler.authentication.AuthenticationApplication` class from your IDE.

Alternatively you can use the [Spring Boot Maven plugin](https://docs.spring.io/spring-boot/docs/current/reference/html/build-tool-plugins-maven-plugin.html).

Navigate to `.../group-project-g1t1-backend/cpa` and execute the following command:

```shell
mvn spring-boot:run
```

By default, the application runs on port 5401.

<p align="right">(<a href="#top">back to top</a>)</p>

## Authentication via JWT

All endpoints (except for `/api/v1/account/create`) require authentication via JWT. This token is issued by the `/login` endpoint.

In order to request a token, a user account must first be created.

```shell
curl --location --request POST 'http://localhost:8080/api/v1/account/create' \
--header 'Content-Type: application/json' \
--data-raw '{
    "email":"new_user@gmail.com",
    "password": "new_user_password"
}'
```

Afterwhich, use the `/login` endpoint to retrieve the JWT token for the user account. Note that the param name for email here is substituted by `username`

```shell
curl -i --location --request POST 'http://localhost:8080/login' --header 'Content-Type: application/json' --data-raw '{
    "username":"new_user@gmail.com",
    "password": "new_user_password"
}'
```

This should return a bearer token. This bearer token must be used to authorize subsequent API calls. For instance, the following should return a `[200]` response:

```shell
curl -i --location --request GET 'http://localhost:8080/api/v1/account/test' --header 'Content-Type: application/json' --header 'Authorization: Bearer XXX'
```

Alternatively, use `scripts/get_access_token.sh` to get an access token printed in your terminal.
```shell
❯ ./scripts/get_access_token.sh

Bearer XXX
```

<p align="right">(<a href="#top">back to top</a>)</p>
