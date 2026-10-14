SET SESSION gold.compression_codec = 'ZSTD';
CREATE SCHEMA IF NOT EXISTS gold.q10;

CREATE TABLE gold.q10.top_returned_customers WITH (format = 'PARQUET') AS
SELECT row_number() OVER (ORDER BY revenue DESC) AS rnk, *
FROM (
  SELECT c.custkey, c.name, sum(r.revenue) AS revenue, c.acctbal,
         c.nation_name AS nation, c.address, c.phone, c.comment
  FROM silver.q10.returned_items    r
  JOIN silver.q10.customer_enriched c ON c.custkey = r.custkey
  WHERE r.orderdate >= DATE '1993-10-01' AND r.orderdate < DATE '1994-01-01'
  GROUP BY c.custkey, c.name, c.acctbal, c.nation_name, c.address, c.phone, c.comment
  ORDER BY revenue DESC
  LIMIT 20
);
