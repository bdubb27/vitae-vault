CREATE TABLE party_relationship (
    relationship_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_party_id UUID NOT NULL REFERENCES party(party_id),
    to_party_id UUID NOT NULL REFERENCES party(party_id),
    relationship_type TEXT NOT NULL,
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_to TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE (from_party_id, to_party_id, relationship_type, valid_from),
    CONSTRAINT chk_relationship_type CHECK (relationship_type IN ('employed_by', 'applicant_to'))
);
