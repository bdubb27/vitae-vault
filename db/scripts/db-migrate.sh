#!/bin/bash
set -e

source "$(dirname "$0")/../config/db-config.sh"

SCHEMA_DIR="$(dirname "$0")/../migrations"

echo "Applying schema migrations..."
for file in "$SCHEMA_DIR"/*.sql; do
    echo "Applying $file..."
    psql -U postgres $DB_HOST -d $DB_NAME -f "$file"
done

echo "Database migrations complete!"
