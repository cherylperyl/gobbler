#!/usr/bin/env bash

set -a # automatically export all variables
source .env
set +a

GCP_ENV_VAR_REF='\/${GCP_PROJECT_ID}'
GCP_PROJECT_ID_DIR="\/$GCP_PROJECT_ID"
find ./kubernetes -type f -exec gsed -i "s/$GCP_ENV_VAR_REF/$GCP_PROJECT_ID_DIR/g" {} +
kubectl apply -R -f ./kubernetes
