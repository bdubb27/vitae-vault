ALTER TABLE party_contact
ALTER COLUMN is_primary SET NOT NULL,
ALTER COLUMN valid_from SET NOT NULL,
ALTER COLUMN created_at SET NOT NULL,
ALTER COLUMN updated_at SET NOT NULL,
ADD CONSTRAINT uq_contact_valid_to UNIQUE NULLS NOT DISTINCT (party_id, contact_type, contact_value, valid_to);
