GCP_ENV_VAR_REF='\/${GCP_PROJECT_ID}'
GCP_PROJECT_ID_DIR="\/$GCP_PROJECT_ID"
gsed -i "s/$GCP_ENV_VAR_REF/$GCP_PROJECT_ID_DIR/g" ./kubernetes/*
kubectl apply -f ./kubernetes
