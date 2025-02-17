CREATE TABLE IF NOT EXISTS party (
    party_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    party_type TEXT NOT NULL,
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_to TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT chk_party_type CHECK (party_type IN ('person', 'organization'))
);
