FROM mcr.microsoft.com/azure-cli as base

RUN apk update
RUN apk upgrade
RUN apk add --no-cache unixodbc-dev g++

RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir dbt-core
RUN pip install --no-cache-dir dbt-snowflake --no-use-pep517
RUN pip install --no-cache-dir dbt-synapse

COPY ./*.sh /
COPY ./*.py /

ENV PYTHONUNBUFFERED=1

RUN chmod 700 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
