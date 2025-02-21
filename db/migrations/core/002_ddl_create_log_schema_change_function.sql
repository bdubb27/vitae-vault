CREATE OR REPLACE FUNCTION log_schema_change(
    p_table_name TEXT,
    p_command TEXT,
    p_filename TEXT
) RETURNS VOID AS $$
DECLARE
    latest_version INT;
BEGIN
    SELECT COALESCE(MAX(version), 0) INTO latest_version
      FROM schema_history
     WHERE table_name = p_table_name
       AND valid_to IS NULL;

    UPDATE schema_history
       SET valid_to = NOW()
     WHERE table_name = p_table_name
       AND valid_to IS NULL;

    INSERT INTO schema_history (table_name, version, ddl_type, filename)
    VALUES (p_table_name, latest_version + 1, p_command, p_filename);

END;
$$ LANGUAGE plpgsql;
