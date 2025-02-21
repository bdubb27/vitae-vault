CREATE TABLE IF NOT EXISTS schema_history (
    schema_history_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    table_name TEXT NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    ddl_type TEXT NOT NULL,
    filename TEXT NOT NULL,

    valid_from TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    valid_to TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    UNIQUE NULLS NOT DISTINCT (table_name, valid_to)
);

INSERT INTO schema_history (table_name, version, ddl_type, filename)
SELECT * FROM (
    VALUES
        ('schema_history', 1, 'CREATE TABLE', 'core/001_ddl_create_schema_history_table.sql')
) AS v(table_name, version, ddl_type, filename)
WHERE NOT EXISTS (
    SELECT 1 FROM schema_history sh
     WHERE sh.table_name = v.table_name
       AND sh.version = v.version
);
