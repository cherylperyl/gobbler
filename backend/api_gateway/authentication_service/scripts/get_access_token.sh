# TARGET_URL='http://localhost:8080'
TARGET_URL='http://localhost:5401'

curl -s --location --request POST "${TARGET_URL}/account/create" \
--header 'Content-Type: application/json' \
--data-raw '{
    "email":"new_user@gmail.com",
    "password": "new_user_password"
}' | echo ""

curl -i -s --location --request POST "${TARGET_URL}/login" --header 'Content-Type: application/json' --data-raw '{
    "username":"new_user@gmail.com",
    "password": "new_user_password"
}' | grep "Authorization" | awk '{print $2 " " $3}'
