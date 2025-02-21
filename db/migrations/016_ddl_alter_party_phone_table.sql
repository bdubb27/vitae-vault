ALTER TABLE party_phone
    DROP CONSTRAINT IF EXISTS party_phone_party_id_phone_type_country_code_area_code_phon_key,
    ADD CONSTRAINT uq_phone_valid_to UNIQUE NULLS NOT DISTINCT (party_id, phone_type, country_code, area_code, phone_number, extension, valid_to);
