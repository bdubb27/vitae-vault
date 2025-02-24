#!/bin/bash
set -e

source "$(dirname "$0")/db-utils.sh"

MIGRATIONS_DIR="$(dirname "$0")/../migrations"
LOG_FILE="/tmp/db_migration_log.txt"

rm -f "$LOG_FILE"

echo "Applying migrations..."
for dir in "core" "."; do
    for file in "${MIGRATIONS_DIR}/${dir}"/*.sql; do
        FILENAME="${dir}/$(basename "$file")"
        FILENAME="${FILENAME#./}"

        SCHEMA_HISTORY_ENABLED=$(run_psql "SELECT 1 FROM information_schema.tables WHERE table_name = 'schema_history'")

        if [[ "$SCHEMA_HISTORY_ENABLED" == 1 ]]; then
            APPLIED=$(run_psql "SELECT 1 FROM schema_history WHERE filename = '$FILENAME'")
        fi

        if [[ -n "$APPLIED" ]]; then
            printf "%s\t%s\t%s\n" "SKIPPING: " "$FILENAME" "already applied" >> "$LOG_FILE"
            continue
        fi

        OUTPUT=$(run_psql --as-postgres -f "$file")
        TARGET=$(grep -oE '^(CREATE|ALTER|DROP|TRUNCATE)( OR REPLACE)? (TABLE|FUNCTION)( IF NOT EXISTS)? [A-Za-z_0-9()]+' "$file" | head -n 1 | awk '{print $NF}' | sed -E 's/\($/()/')

        PSQL_NOTICE=$(echo "$OUTPUT" | awk -F': NOTICE:  ' 'NF>1 {print $2}')
        PSQL_ERROR=$(echo "$OUTPUT" | awk -F': ERROR:  ' 'NF>1 {print $2}')
        PSQL_NOTICE_COMMAND=$(echo "$OUTPUT" | awk '/: NOTICE:  / {getline; print}' | grep -oE '^(CREATE|ALTER|DROP|TRUNCATE) (TABLE|FUNCTION|SCHEMA|INDEX|TRIGGER|VIEW|SEQUENCE|TYPE)' || echo "UNKNOWN")
        PSQL_ERROR_COMMAND=$(echo "$OUTPUT" | awk '/: ERROR:  / {getline; print}' | grep -oE '^(CREATE|ALTER|DROP|TRUNCATE) (TABLE|FUNCTION|SCHEMA|INDEX|TRIGGER|VIEW|SEQUENCE|TYPE)' || echo "UNKNOWN")
        PSQL_COMMAND=$(echo "$OUTPUT" | grep -oE '^(CREATE|ALTER|DROP|TRUNCATE) (TABLE|FUNCTION|SCHEMA|INDEX|TRIGGER|VIEW|SEQUENCE|TYPE)' | head -n 1 || echo "UNKNOWN")
        LOG_SCHEMA_CHANGE_ENABLED=$(run_psql "SELECT 1 FROM pg_proc WHERE pg_proc.proname = 'log_schema_change';")


        if [[ -n "$PSQL_NOTICE" ]]; then
            printf "%s\t%s\t%s\t%s\t%s\n" "NOTICE: " "$FILENAME" "$PSQL_NOTICE_COMMAND" "$TARGET" "$PSQL_NOTICE" >> "$LOG_FILE"
        fi

        if [[ -n "$PSQL_ERROR" ]]; then
            printf "%s\t%s\t%s\t%s\t%s\n" "ERROR: " "$FILENAME" "$PSQL_ERROR_COMMAND" "$TARGET" "$PSQL_ERROR" >> "$LOG_FILE"
        fi

        if [[ -z "$PSQL_NOTICE" && -z "$PSQL_ERROR" ]]; then
            printf "%s\t%s\t%s\t%s\n" "SUCCESS: " "$FILENAME" "$PSQL_COMMAND" "$TARGET" >> "$LOG_FILE"

            if [[ -n "$SCHEMA_HISTORY_ENABLED" && "$LOG_SCHEMA_CHANGE_ENABLED" ]]; then
                run_psql "SELECT log_schema_change('$TARGET', '$PSQL_COMMAND', '$FILENAME')"
            fi
        fi

    done
done

awk -F'\t' '{printf "%-10s %-50s %-16s %s\n", $1, $2, $3, $4}' "$LOG_FILE"

echo "Executing apply_updated_at_triggers()..."
run_psql --as-postgres "SELECT apply_updated_at_triggers();"

echo "Database migrations complete!"
