# © 2022 Divergent Insights Pty Ltd - <info@divergentinsights.com.au>

#!/bin/sh

echo "Copying and untaring dbt project"
cp $ENV_DBT_PROJECT_TAR /
tar -xvf /dbtproject.tar
ls -l /dbtproject
ls -l $HOME/.dbt

cd /dbtproject
dbt debug
dbt run
