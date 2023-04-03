# Kong

## Authentication via JWT

All non-public endpoints require authentication via JWT. This token is issued by the `/user/loginuser` endpoint.

In order to request a token, a user account must first be created.

```shell
curl -i -s --location --request POST "http://gobbler.world/user/createaccount" \
--header 'Content-Type: application/json' \
--data-raw '{
	"email": "new_user@gmail.com",
    "username":"new_user@gmail.com",
    "password": "new_user_password"
}'
```

Afterwhich, use the `/loginuser` endpoint to retrieve the JWT token for the user account. Note that the param name for email here is substituted by `username`

```shell
curl -i --location --request POST 'http://gobbler.world/user/loginuser' --header 'Content-Type: application/json' --data-raw '{
    "username":"new_user@gmail.com",
    "password": "new_user_password"
}'
```

## Rate Limiting

Rate limits are set to global requests of 100 requests per minute.
