ALTER TABLE organization
    ALTER COLUMN valid_from SET NOT NULL,
    ALTER COLUMN created_at SET NOT NULL,
    ALTER COLUMN updated_at SET NOT NULL;
