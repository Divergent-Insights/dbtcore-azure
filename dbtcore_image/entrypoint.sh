#!/bin/sh

echo "Copying and untaring dbt project"
cp $ENV_DBT_PROJECT_TAR /
tar -xvf /data.tar
ls -l /data
ls -l $HOME/.dbt

cd /data
dbt debug
dbt run
