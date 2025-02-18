CREATE TABLE schema_history (
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

INSERT INTO schema_history (table_name, ddl_type, filename)
VALUES
    ('party', 'CREATE', '001_ddl_create_party_table.sql'),
    ('person', 'CREATE', '002_ddl_create_person_table.sql'),
    ('organization', 'CREATE', '003_ddl_create_organization_table.sql'),
    ('party_role', 'CREATE', '004_ddl_create_party_role_table.sql'),
    ('party_relationship', 'CREATE', '005_ddl_create_party_relationship_table.sql'),
    ('party_contact', 'CREATE', '006_ddl_create_party_contact_table.sql'),
    ('party_address', 'CREATE', '007_ddl_create_party_address_table.sql'),
    ('party_phone', 'CREATE', '008_ddl_create_party_phone_table.sql'),
    ('schema_history', 'CREATE', '009_ddl_create_schema_history_table.sql'),
    ('update_timestamp()', 'CREATE', '801_ddl_create_updated_at_trigger.sql');
