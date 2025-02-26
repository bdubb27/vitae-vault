ALTER TABLE party_address
ALTER COLUMN party_id SET NOT NULL,
ALTER COLUMN is_primary SET NOT NULL,
ALTER COLUMN valid_from SET NOT NULL,
ALTER COLUMN created_at SET NOT NULL,
ALTER COLUMN updated_at SET NOT NULL,
DROP CONSTRAINT IF EXISTS party_address_party_id_street_address_city_state_zip_code_key,
ADD CONSTRAINT uq_address_valid_to UNIQUE NULLS NOT DISTINCT (party_id, street_address, city, state, zip_code, country, valid_to);
