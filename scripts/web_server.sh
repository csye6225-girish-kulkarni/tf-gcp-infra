#!/bin/bash

# Get the values from Terraform output
DB_INSTANCE_CONNECTION_NAME=$(terraform output -raw db_instance_connection_name)
DB_USER_PASSWORD=$(terraform output -raw db_user_password)

# Construct the PostgreSQL connection string
POSTGRES_CONN_STR="postgresql://webapp:${DB_USER_PASSWORD}@/${DB_INSTANCE_CONNECTION_NAME}"

# Write the connection string to the webapp.env file
echo "POSTGRES_CONN_STR=${POSTGRES_CONN_STR}" > /usr/bin/webapp.env
sudo chown csye6225:csye6225 /usr/bin/webapp.env
sudo chmod 644 /usr/bin/webapp.env