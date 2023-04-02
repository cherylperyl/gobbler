set -a # automatically export all variables
source .env
set +a

docker compose build
docker compose push

GCP_ENV_VAR_REF='\/${GCP_PROJECT_ID}'
GCP_PROJECT_ID_DIR="\/$GCP_PROJECT_ID"
find ./kubernetes -type f -exec sed -i "s/$GCP_ENV_VAR_REF/$GCP_PROJECT_ID_DIR/g" {} +
kubectl apply -R -f ./kubernetes
find ./kubernetes -type f -exec sed -i "s/$GCP_PROJECT_ID_DIR/$GCP_ENV_VAR_REF/g" {} +
kubectl rollout restart deployment -n default
