ALTER TABLE party_relationship
ALTER COLUMN valid_from SET NOT NULL,
ALTER COLUMN created_at SET NOT NULL,
ALTER COLUMN updated_at SET NOT NULL,
DROP CONSTRAINT IF EXISTS party_relationship_from_party_id_to_party_id_relationship_t_key,
ADD CONSTRAINT uq_relationship_valid_to UNIQUE NULLS NOT DISTINCT (from_party_id, to_party_id, relationship_type, valid_to);
