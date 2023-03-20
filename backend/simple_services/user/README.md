# User Microservice
Stores user data. See [Database Schema](#database-schema) to see what details are stored.
___
## To run
`docker compose up --build`

Use browser to access http://localhost:8081/swagger/index.html to view and test the available endpoints.  
  
To shut down: `docker compose down`

## References
- [How to containerise Web API with Docker & use PostgreSQL](https://www.youtube.com/watch?v=9ZEbJT36-Uk&ab_channel=MohamadLawand)
- [Code to add automatic migration in docker](https://stackoverflow.com/questions/72059441/automatic-net-6-ef-migration-fails-in-docker)
- [psql: FATAL: password authentication failed for user "postgres"](https://github.com/sameersbn/docker-postgresql/issues/112)
- [how to use dotnet restore properly in dockerfile](https://stackoverflow.com/questions/53460002/how-to-use-dotnet-restore-properly-in-dockerfile)

