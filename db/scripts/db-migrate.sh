#!/bin/bash
set -e

source "$(dirname "$0")/../config/db-config.sh"

MIGRATIONS_DIR="$(dirname "$0")/../migrations"

echo "Applying migrations..."
for file in "$MIGRATIONS_DIR"/*.sql; do
    echo "Applying ${file##*/}..."
    psql -U postgres $DB_HOST -d $DB_NAME -f "$file"
done

echo "Database migrations complete!"
