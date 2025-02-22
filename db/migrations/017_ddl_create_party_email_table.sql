CREATE TABLE IF NOT EXISTS party_email (
    email_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    party_id UUID NOT NULL,
    email_type TEXT NOT NULL,
    email TEXT NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    valid_from TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    valid_to TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_party FOREIGN KEY (party_id) REFERENCES party(party_id) ON DELETE CASCADE,

    CONSTRAINT uq_email_valid_to UNIQUE NULLS NOT DISTINCT (party_id, email, valid_to),

    CONSTRAINT chk_email_type CHECK (email_type IN ('home', 'work', 'other')),
    CONSTRAINT chk_email_format CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')  -- FIXME: likely not 100% accurate
);
