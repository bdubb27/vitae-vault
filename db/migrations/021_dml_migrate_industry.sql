BEGIN;

INSERT INTO industry (industry_name)
SELECT DISTINCT industry
FROM organization
WHERE industry IS NOT NULL;

INSERT INTO organization_industry (organization_id, industry_id, is_primary)
SELECT o.party_id, i.industry_id, TRUE
FROM organization o
JOIN industry i ON o.industry = i.industry_name
WHERE o.industry IS NOT NULL;

ALTER TABLE organization DROP COLUMN industry;

COMMIT;
