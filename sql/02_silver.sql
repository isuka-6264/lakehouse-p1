SET SESSION silver.compression_codec = 'ZSTD';
CREATE SCHEMA IF NOT EXISTS silver.q10;

CREATE TABLE silver.q10.customer_enriched WITH (format = 'PARQUET') AS
SELECT c.custkey,
       trim(c.name)                    AS name,
       trim(c.address)                 AS address,
       trim(c.phone)                   AS phone,
       CAST(c.acctbal AS decimal(12,2)) AS acctbal,
       trim(c.comment)                 AS comment,
       trim(n.name)                    AS nation_name
FROM bronze.q10.customer c
JOIN bronze.q10.nation   n ON c.nationkey = n.nationkey
WHERE c.custkey IS NOT NULL;

CREATE TABLE silver.q10.returned_items
WITH (format = 'PARQUET', partitioning = ARRAY['year(orderdate)']) AS
SELECT l.orderkey,
       l.linenumber,
       o.custkey,
       o.orderdate,
       CAST(l.extendedprice AS decimal(12,2)) AS extendedprice,
       CAST(l.discount      AS decimal(4,2))  AS discount,
       CAST(l.extendedprice AS decimal(12,2)) * (1 - CAST(l.discount AS decimal(4,2))) AS revenue
FROM bronze.q10.lineitem l
JOIN bronze.q10.orders   o ON l.orderkey = o.orderkey
WHERE l.returnflag = 'R'
  AND l.extendedprice > 0
  AND l.discount BETWEEN 0 AND 1
  AND o.orderdate IS NOT NULL;
