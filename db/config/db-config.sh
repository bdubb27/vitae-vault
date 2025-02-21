#!/bin/bash

DB_USER="vitae_vault"
DB_NAME="vitae_vault_db"
SCHEMA_NAME="vitae_vault"

# Detect execution context
if [ -f /.dockerenv ]; then
    DB_HOST=()  # Inside Docker, use Unix socket
else
    DB_HOST=(-h "localhost")  # On host machine, use localhost
fi
