CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE r RECORD;
BEGIN
    FOR r IN
        SELECT t.tablename
        FROM pg_tables t
        JOIN information_schema.columns c
            ON t.tablename = c.table_name
        WHERE c.column_name = 'updated_at'
    LOOP
        EXECUTE format(
            'CREATE OR REPLACE TRIGGER trigger_update_%I
             BEFORE UPDATE ON %I
             FOR EACH ROW
             WHEN (OLD.* IS DISTINCT FROM NEW.*)
             EXECUTE FUNCTION update_timestamp();',
            r.tablename, r.tablename
        );
    END LOOP;
END $$;
