CREATE TABLE IF NOT EXISTS schema_history (
    schema_history_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    table_name TEXT,
    version INTEGER NOT NULL DEFAULT 1,
    ddl_type TEXT NOT NULL,
    filename TEXT NOT NULL,

    valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_to TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE NULLS NOT DISTINCT (table_name, valid_to),
    CONSTRAINT chk_ddl_type CHECK (ddl_type IN ('CREATE', 'ALTER', 'DROP', 'TRUNCATE', 'ROLLBACK'))
);

INSERT INTO schema_history (table_name, version, ddl_type, filename)
SELECT * FROM (
    VALUES
        ('party', 1, 'CREATE', '001_ddl_create_party_table.sql'),
        ('person', 1, 'CREATE', '002_ddl_create_person_table.sql'),
        ('organization', 1, 'CREATE', '003_ddl_create_organization_table.sql'),
        ('party_role', 1, 'CREATE', '004_ddl_create_party_role_table.sql'),
        ('party_relationship', 1, 'CREATE', '005_ddl_create_party_relationship_table.sql'),
        ('party_contact', 1, 'CREATE', '006_ddl_create_party_contact_table.sql'),
        ('party_address', 1, 'CREATE', '007_ddl_create_party_address_table.sql'),
        ('party_phone', 1, 'CREATE', '008_ddl_create_party_phone_table.sql'),
        ('schema_history', 1, 'CREATE', '009_ddl_create_schema_history_table.sql'),
        ('update_timestamp()', 1, 'CREATE', '801_ddl_create_updated_at_trigger.sql')
) AS v(table_name, version, ddl_type, filename)
WHERE NOT EXISTS (
    SELECT 1 FROM schema_history sh
    WHERE sh.table_name = v.table_name
    AND sh.version = v.version
);
