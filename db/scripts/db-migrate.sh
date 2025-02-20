#!/bin/bash
set -e

source "$(dirname "$0")/../config/db-config.sh"

MIGRATIONS_DIR="$(dirname "$0")/../migrations"
LOG_FILE="/tmp/db_migration_log.txt"

rm -f "$LOG_FILE"

echo "Applying migrations..."
for file in "$MIGRATIONS_DIR"/*.sql; do
    FILENAME=$(basename "$file")
    SCHEMA_HISTORY_ENABLED=$(psql -U postgres $DB_HOST -d $DB_NAME -tAc "SELECT 1 FROM information_schema.tables WHERE table_name = 'schema_history'")

    if [[ -z "$SCHEMA_HISTORY_ENABLED" ]]; then
        APPLIED=0
    else
        APPLIED=$(psql -U postgres $DB_HOST -d $DB_NAME -tAc "SELECT 1 FROM schema_history WHERE filename = '$FILENAME'")
    fi

    if [[ "$APPLIED" == "1" ]]; then
        printf "%s\t%s\t%s\n" "SKIPPING: " "$FILENAME" "already applied" >> "$LOG_FILE"
        continue
    fi

    OUTPUT=$(psql -U postgres $DB_HOST -d $DB_NAME -f "$file" 2>&1)
    TARGET=$(head -1 < "$file" | grep -oE '^(CREATE|ALTER|DROP|TRUNCATE)( OR REPLACE)? (TABLE|FUNCTION)( IF NOT EXISTS)? [a-zA-Z_0-9()]+' | awk '{print $NF}' | sed -E 's/\($/()/')

    PSQL_NOTICE=$(echo "$OUTPUT" | awk -F': NOTICE:  ' 'NF>1 {print $2}')
    PSQL_ERROR=$(echo "$OUTPUT" | awk -F': ERROR:  ' 'NF>1 {print $2}')
    PSQL_NOTICE_COMMAND=$(echo "$OUTPUT" | awk '/: NOTICE:  / {getline; print}' | grep -oE '^(CREATE|ALTER|DROP|TRUNCATE) (TABLE|FUNCTION|SCHEMA|INDEX|TRIGGER|VIEW|SEQUENCE|TYPE)' || echo "UNKNOWN")
    PSQL_ERROR_COMMAND=$(echo "$OUTPUT" | awk '/: ERROR:  / {getline; print}' | grep -oE '^(CREATE|ALTER|DROP|TRUNCATE) (TABLE|FUNCTION|SCHEMA|INDEX|TRIGGER|VIEW|SEQUENCE|TYPE)' || echo "UNKNOWN")
    PSQL_COMMAND=$(echo "$OUTPUT" | grep -oE '^(CREATE|ALTER|DROP|TRUNCATE) (TABLE|FUNCTION|SCHEMA|INDEX|TRIGGER|VIEW|SEQUENCE|TYPE)' || echo "UNKNOWN")
    LOG_SCHEMA_CHANGE_ENABLED=$(psql -U postgres $DB_HOST -d $DB_NAME -tAc "SELECT 1 FROM pg_proc WHERE pg_proc.proname = 'log_schema_change';")


    if [[ -n "$PSQL_NOTICE" ]]; then
        printf "%s\t%s\t%s\t%s\t%s\n" "NOTICE: " "$FILENAME" "$PSQL_NOTICE_COMMAND" "$TARGET" "$PSQL_NOTICE" >> "$LOG_FILE"
    fi

    if [[ -n "$PSQL_ERROR" ]]; then
        printf "%s\t%s\t%s\t%s\t%s\n" "ERROR: " "$FILENAME" "$PSQL_ERROR_COMMAND" "$TARGET" "$PSQL_ERROR" >> "$LOG_FILE"
    fi

    if [[ -z "$PSQL_NOTICE" && -z "$PSQL_ERROR" ]]; then
        printf "%s\t%s\t%s\t%s\n" "SUCCESS: " "$FILENAME" "$PSQL_COMMAND" "$TARGET" >> "$LOG_FILE"
    fi

    if [[ -n "$SCHEMA_HISTORY_ENABLED" && "$LOG_SCHEMA_CHANGE_ENABLED" ]]; then
        psql -U postgres $DB_HOST -d $DB_NAME -tAc "SELECT log_schema_change('$TARGET', '$PSQL_COMMAND', '$FILENAME')"
    fi

done

awk -F'\t' '{printf "%-10s %-45s %-16s %s\n", $1, $2, $3, $4}' "$LOG_FILE"

echo "Database migrations complete!"
