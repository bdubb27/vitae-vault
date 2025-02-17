CREATE TABLE party_contact (
    contact_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    party_id UUID NOT NULL REFERENCES party(party_id),
    contact_type TEXT NOT NULL,
    contact_value TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_to TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT chk_contact_type CHECK (contact_type in ( 'phone', 'email', 'linkedin', 'github'))
);
