ALTER TABLE schema_history DROP CONSTRAINT IF EXISTS chk_ddl_type;

UPDATE schema_history
SET ddl_type = CASE
    WHEN table_name LIKE '%()' THEN 'CREATE FUNCTION'
    ELSE 'CREATE TABLE'
END
WHERE version = 1
AND ddl_type NOT IN ('CREATE TABLE', 'CREATE FUNCTION');

WITH expired AS (
    UPDATE schema_history
       SET valid_to = NOW()
     WHERE table_name = 'schema_history'
       AND version = 1
       AND valid_to IS NULL
    RETURNING table_name, version
),
new_entry AS (
    INSERT INTO schema_history (table_name, version, ddl_type, filename)
    SELECT expired.table_name, expired.version + 1, 'ALTER TABLE', '010_ddl_alter_schema_history_table.sql'
    FROM expired
    WHERE NOT EXISTS (
        SELECT 1 FROM schema_history sh
        WHERE sh.table_name = expired.table_name
        AND sh.version = expired.version + 1
    )
    RETURNING schema_history_id
)
SELECT schema_history_id from new_entry;
