TARGET_URL='http://localhost:8080'

curl -s --location --request POST "${TARGET_URL}/api/v1/account/create" \
--header 'Content-Type: application/json' \
--data-raw '{
    "email":"new_user@gmail.com",
    "password": "new_user_password"
}' | echo ""

curl -i -s --location --request POST "${TARGET_URL}/login" --header 'Content-Type: application/json' --data-raw '{
    "username":"new_user@gmail.com",
    "password": "new_user_password"
}' | grep "Authorization" | awk '{print $2 " " $3}'

# curl -i -s --location --request GET "http://localhost:8080/api/v1/account/me" \ -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJuZXdfdXNlckBnbWFpbC5jb20iLCJleHAiOjE2Nzg2NDE0Mzl9.arG8IjfMMP_k_vUuzoUXQ34WVvx7mb-LxAJ1DjDkG4QRlpmkXRW0B9Th7GghOkli-dwyFn1BkJWKtMlJlcpwZg'