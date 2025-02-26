CREATE TABLE IF NOT EXISTS organization_industry (
    organization_id UUID NOT NULL,
    industry_id UUID NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    valid_from TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    valid_to TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_organization_industry PRIMARY KEY (organization_id, industry_id, valid_from),

    CONSTRAINT fk_organization FOREIGN KEY (organization_id) REFERENCES organization(party_id) ON DELETE CASCADE,
    CONSTRAINT fk_industry FOREIGN KEY (industry_id) REFERENCES industry(industry_id) ON DELETE CASCADE,

    CONSTRAINT uq_organization_industry_valid_to UNIQUE NULLS NOT DISTINCT (organization_id, industry_id, valid_to)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_organization_primary_industry ON organization_industry (organization_id) WHERE is_primary = TRUE AND valid_to IS NULL;
