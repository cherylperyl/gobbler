#!/usr/bin/env bash

GCP_ENV_VAR_REF='\/${GCP_PROJECT_ID}'
GCP_PROJECT_ID_DIR="\/$GCP_PROJECT_ID"
find ./kubernetes -type f -exec gsed -i "s/$GCP_ENV_VAR_REF/$GCP_PROJECT_ID_DIR/g" {} +
