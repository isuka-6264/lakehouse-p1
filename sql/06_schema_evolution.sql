ALTER TABLE silver.q10.customer_enriched ADD COLUMN mktsegment varchar;
SELECT custkey, name, mktsegment FROM silver.q10.customer_enriched ORDER BY custkey LIMIT 3;

MERGE INTO silver.q10.customer_enriched t
USING bronze.q10.customer b ON t.custkey = b.custkey
WHEN MATCHED THEN UPDATE SET mktsegment = trim(b.mktsegment);
SELECT custkey, name, mktsegment FROM silver.q10.customer_enriched ORDER BY custkey LIMIT 3;

ALTER TABLE silver.q10.customer_enriched RENAME COLUMN phone TO phone_number;
SELECT custkey, phone_number FROM silver.q10.customer_enriched ORDER BY custkey LIMIT 2;
ALTER TABLE silver.q10.customer_enriched RENAME COLUMN phone_number TO phone;
