#!/bin/bash
set -e
shopt -s nullglob

source "$(dirname "$0")/db-utils.sh"

SEEDS_DIR="$(dirname "$0")/../seeds"
SEED_FILES=("${SEEDS_DIR}"/*.sql)

echo "Applying seed files..."

if [[ ${#SEED_FILES[@]} -eq 0 ]]; then
    echo "No seed files found, skipping"
fi

for file in "${SEED_FILES[@]}"; do
    run_psql -f "$file"
done

echo "Database seeding complete!"
