CREATE TABLE IF NOT EXISTS party_phone (
    phone_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    party_id UUID NOT NULL REFERENCES party(party_id) ON DELETE CASCADE,
    phone_type TEXT NOT NULL,
    country_code TEXT NOT NULL DEFAULT '1',
    area_code TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    extension TEXT,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    valid_from TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    valid_to TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    UNIQUE NULLS NOT DISTINCT (party_id, phone_type, country_code, area_code, phone_number, extension, valid_to),
    CONSTRAINT chk_phone_type CHECK (phone_type IN ('mobile', 'home', 'work', 'other')),
    CONSTRAINT chk_country_code_format CHECK (country_code ~ '^\d{1,3}$'),
    CONSTRAINT chk_area_code_format CHECK (area_code ~ '^\d{3}$'),  -- FIXME: limiting to 3-digit area codes - consider i18n
    CONSTRAINT chk_phone_number_format CHECK (phone_number ~ '^\d{7}$')  -- FIXME: limiting to 7-digits - consider i18n
);
