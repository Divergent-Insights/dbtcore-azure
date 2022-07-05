#!/bin/bash

echo "Copying and untaring dbt project"
cp $ENV_DBT_PROJECT_TAR /tmp
tar -xvf /tmp/data.tar
ls -l /tmp/data/

#/run_pipeline.sh "$ENV_DBT_RUN_CMD"
