##!/bin/bash
###########################################################
## This script is meant to read the snowflake connection information
## and export them as environment variables
##
###########################################################
#
## Retreive the snowflake connection by reading up the information
## from key vault. To retreive this, use the user assigned identity
#
##azrm_token=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true | jq -r '.access_token')
#
#echo " ------------------------------------- "
#echo "  Initializing snowflake connection info ..."
#
## The below reterieves an access token for key vault. This would allow
## us to read the secrets
#kv_token=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -H Metadata:true | jq -r '.access_token')
#
#####################################################
###  Extract the secrets from the key vault and export the connection variables
#####################################################
#echo "Retrieving snowflake connecting info ..."
#kv_url="$ENV_KV_URL/secrets/$ENV_KV_SFLK"
#export SFLK_CONN_RAW=$(curl "$kv_url/?api-version=2016-10-01"  -H "Authorization: Bearer $kv_token" )
#export SFLK_INFO_PARSED=$(echo $SFLK_CONN_RAW | jq -r '.value' | tr -d '\n' | sed "s/'/\"/g")
#
##echo "SFLK INFO_PARSED : $SFLK_INFO_PARSED "
#
## We use python to extract json value instead of popular jq command, to keep docker size to minimal
## hence we are doing this extraction using python
#export SNOWSQL_ACCOUNT=$(echo $SFLK_INFO_PARSED | jq -r '.SNOWSQL_ACCOUNT')
#export SNOWSQL_USER=$(echo $SFLK_INFO_PARSED | jq -r '.SNOWSQL_USER')
#export DBT_PASSWORD=$(echo $SFLK_INFO_PARSED | jq -r '.DBT_PASSWORD')
#export SNOWSQL_ROLE=$(echo $SFLK_INFO_PARSED | jq -r '.SNOWSQL_ROLE')
#export SNOWSQL_DATABASE=$(echo $SFLK_INFO_PARSED | jq -r '.SNOWSQL_DATABASE')
#export SNOWSQL_WAREHOUSE=$(echo $SFLK_INFO_PARSED | jq -r '.SNOWSQL_WAREHOUSE')
#
##echo "$SNOWSQL_ACCOUNT / $SNOWSQL_USER / $DBT_PASSWORD / $SNOWSQL_ROLE / $SNOWSQL_DATABASE / $SNOWSQL_WAREHOUSE "
#
#