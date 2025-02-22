BEGIN;

INSERT INTO party_phone (party_id, phone_type, country_code, area_code, phone_number, is_primary, valid_from, valid_to, created_at, updated_at)
SELECT
    party_id,
    'mobile',
    COALESCE(NULLIF((regexp_match(contact_value, '^\+?([0-9]{1,3})'))[1], ''), '1')::TEXT,
    SUBSTRING(regexp_replace(contact_value, '[^0-9]', '', 'g') FROM (LENGTH((regexp_match(contact_value, '^\+?([0-9]{1,3})'))[1]) + 1) FOR 3)::TEXT,
    SUBSTRING(regexp_replace(contact_value, '[^0-9]', '', 'g') FROM (LENGTH((regexp_match(contact_value, '^\+?([0-9]{1,3})'))[1]) + 4))::TEXT,
    is_primary,
    valid_from,
    valid_to,
    created_at,
    updated_at
FROM party_contact
WHERE contact_type = 'phone';

INSERT INTO party_email (party_id, email_type, email, is_primary, valid_from, valid_to, created_at, updated_at)
SELECT
    party_id,
    'home',
    contact_value,
    is_primary,
    valid_from,
    valid_to,
    created_at,
    updated_at
FROM party_contact
WHERE contact_type = 'email';

DELETE FROM party_contact WHERE contact_type IN ('email', 'phone');

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM party_contact WHERE contact_type IN ('email', 'phone')) THEN
        RAISE EXCEPTION 'Migration incomplete! Some party_contact records still have email/phone data.';
    END IF;
END $$;

ALTER TABLE party_contact DROP CONSTRAINT chk_contact_type;
ALTER TABLE party_contact ADD CONSTRAINT chk_contact_type CHECK (contact_type IN ('linkedin', 'github'));

COMMIT;
