#!/bin/bash
set -e

source "$(dirname "$0")/config/db-config.sh"

echo "Waiting for PostgreSQL to be ready..."
until psql -U postgres $DB_HOST -tAc "SELECT 1;" >/dev/null 2>&1; do
  sleep 1
done

echo "Checking if database '$DB_NAME' exists..."
if psql -U postgres $DB_HOST -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1; then
    echo "Database '$DB_NAME' already exists."
else
    echo "Creating database '$DB_NAME'..."
    psql -U postgres $DB_HOST -c "CREATE DATABASE $DB_NAME;"
    echo "Database '$DB_NAME' created successfully."
fi

psql -U postgres $DB_HOST -d "$DB_NAME" -c "CREATE SCHEMA IF NOT EXISTS $SCHEMA_NAME;"
echo "Setting default search path to '$SCHEMA_NAME'..."
psql -U postgres $DB_HOST -d "$DB_NAME" -c "ALTER DATABASE $DB_NAME SET search_path TO $SCHEMA_NAME, public;"

echo "Checking if user '$DB_USER' exists..."
if psql -U postgres $DB_HOST -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1; then
    echo "User '$DB_USER' already exists."
else
    echo "Creating user '$DB_USER'..."
    psql -U postgres $DB_HOST -c "CREATE USER $DB_USER;"
    echo "User '$DB_USER' created successfully."
fi

echo "Granting privileges to user '$DB_USER'..."
psql -U postgres $DB_HOST -c "GRANT CONNECT ON DATABASE $DB_NAME TO $DB_USER;"
psql -U postgres $DB_HOST -d "$DB_NAME" -c "GRANT USAGE ON SCHEMA $SCHEMA_NAME TO $DB_USER;"
psql -U postgres $DB_HOST -d "$DB_NAME" -c "GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA $SCHEMA_NAME TO $DB_USER;"
psql -U postgres $DB_HOST -d "$DB_NAME" -c "GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA $SCHEMA_NAME TO $DB_USER;"
psql -U postgres $DB_HOST -d "$DB_NAME" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA $SCHEMA_NAME GRANT SELECT, INSERT, UPDATE ON TABLES TO $DB_USER;"

echo "Ensuring UUID extension is enabled..."
psql -U postgres $DB_HOST -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\" SCHEMA public;"

echo "Running database migrations..."
"$(dirname "$0")/scripts/db-migrate.sh"

echo "Seeding database..."
"$(dirname "$0")/scripts/db-seed.sh"

echo "Database initialization complete!"
