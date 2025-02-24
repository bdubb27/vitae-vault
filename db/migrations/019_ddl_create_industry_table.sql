CREATE TABLE IF NOT EXISTS industry (
    industry_id UUID DEFAULT uuid_generate_v4(),
    industry_name TEXT NOT NULL,

    valid_from TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    valid_to TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_industry PRIMARY KEY (industry_id),

    CONSTRAINT uq_industry_name UNIQUE NULLS NOT DISTINCT (industry_name, valid_to)
);
