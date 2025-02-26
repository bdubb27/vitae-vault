BEGIN;

ALTER TABLE party_relationship
DROP CONSTRAINT IF EXISTS uq_relationship_valid_to,
DROP CONSTRAINT IF EXISTS party_relationship_from_party_id_fkey,
DROP CONSTRAINT IF EXISTS party_relationship_to_party_id_fkey;


ALTER TABLE party_relationship RENAME COLUMN from_party_id TO from_party_role_id;
ALTER TABLE party_relationship RENAME COLUMN to_party_id TO to_party_role_id;

UPDATE party_relationship pr
SET from_party_role_id = (
    SELECT prl.role_id
    FROM party_role prl
    WHERE prl.party_id = pr.from_party_role_id
      AND prl.valid_from = pr.valid_from
      AND prl.valid_to IS NOT DISTINCT FROM pr.valid_to
    LIMIT 1
);

UPDATE party_relationship pr
SET to_party_role_id = (
    SELECT prl.role_id
    FROM party_role prl
    WHERE prl.party_id = pr.to_party_role_id
      AND prl.valid_from = pr.valid_from
      AND prl.valid_to IS NOT DISTINCT FROM pr.valid_to
    LIMIT 1
);

ALTER TABLE party_relationship
ADD CONSTRAINT fk_from_role FOREIGN KEY (from_party_role_id) REFERENCES party_role(role_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_to_role FOREIGN KEY (to_party_role_id) REFERENCES party_role(role_id) ON DELETE CASCADE,

ADD CONSTRAINT uq_relationship_valid_to UNIQUE NULLS NOT DISTINCT (from_party_role_id, to_party_role_id, relationship_type, valid_to);

COMMIT;
