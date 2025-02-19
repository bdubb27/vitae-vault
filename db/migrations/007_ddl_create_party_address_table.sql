CREATE TABLE IF NOT EXISTS party_address (
    address_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    party_id UUID REFERENCES party(party_id) ON DELETE CASCADE,
    street_address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip_code TEXT NOT NULL,
    country TEXT NOT NULL DEFAULT 'USA',
    is_primary BOOLEAN DEFAULT FALSE,
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_to TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE (party_id, street_address, city, state, zip_code),
    CONSTRAINT chk_state_length CHECK (LENGTH(state) = 2),
    CONSTRAINT chk_zip_format CHECK (zip_code ~ '^\d{5}(-\d{4})?$')
);
