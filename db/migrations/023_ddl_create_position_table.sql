CREATE TABLE IF NOT EXISTS position (
    position_id UUID DEFAULT uuid_generate_v4(),

    role_id UUID NOT NULL,
    title TEXT NOT NULL,
    level TEXT,
    employment_type TEXT CHECK (employment_type IN ('full-time', 'part-time', 'contract', 'intern', 'freelance')),
    department TEXT,
    location TEXT,

    valid_from TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    valid_to TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_position PRIMARY KEY (position_id),

    CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES party_role(role_id) ON DELETE CASCADE,

    CONSTRAINT uq_position UNIQUE (role_id, title, valid_from)
);
