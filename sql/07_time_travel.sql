-- 1. Accidental change
UPDATE silver.q10.customer_enriched SET acctbal = 0 WHERE nation_name = 'JAPAN';

-- 2. Compare now vs the past (time travel read)
SELECT 'now' AS version, sum(acctbal) AS japan_acctbal FROM silver.q10.customer_enriched WHERE nation_name = 'JAPAN'
UNION ALL
SELECT 'before', sum(acctbal) FROM silver.q10.customer_enriched FOR VERSION AS OF 2358026435400632268 WHERE nation_name = 'JAPAN';

-- 3. Recovery: roll the table back to the snapshot before the mistake
ALTER TABLE silver.q10.customer_enriched EXECUTE rollback_to_snapshot(2358026435400632268);

-- 4. Check
SELECT 'after rollback' AS version, sum(acctbal) AS japan_acctbal FROM silver.q10.customer_enriched WHERE nation_name = 'JAPAN';
