CREATE TABLE IF NOT EXISTS party_role (
    role_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    party_id UUID NOT NULL REFERENCES party(party_id) ON DELETE CASCADE,
    role TEXT NOT NULL,
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_to TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CONSTRAINT chk_role CHECK (role IN ('employee', 'applicant', 'employer'))
);
