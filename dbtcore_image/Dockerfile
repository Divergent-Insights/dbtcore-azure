# © 2022 Divergent Insights Pty Ltd - <info@divergentinsights.com.au>

FROM mcr.microsoft.com/azure-cli as base

RUN apk update
RUN apk upgrade
RUN apk add --no-cache unixodbc-dev g++

# Microsoft SQL Server and Synapse Drivers
RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.8.1.1-1_amd64.apk
RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.8.1.1-1_amd64.apk
RUN apk add --allow-untrusted msodbcsql17_17.8.1.1-1_amd64.apk
RUN apk add --allow-untrusted mssql-tools_17.8.1.1-1_amd64.apk

# Installing Python dependencies
# Hiding output with -q as there are enconding issues with Windows
RUN pip install -q --upgrade pip setuptools wheel
RUN pip install -q --no-cache-dir dbt-core
RUN pip install -q --no-cache-dir dbt-synapse

# Adding supporting files
COPY ./*.sh /

# Configuring dbt profiles
RUN mkdir /root/.dbt
ADD profiles.yml /root/.dbt
# This step is redundant but it does not hurt
ENV DBT_PROFILES_DIR /root/.dbt

# Uncomment this to aid local development / testing
#ADD test/dbtproject.tar /

ENV PYTHONUNBUFFERED=1

RUN chmod 700 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
