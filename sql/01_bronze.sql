SET SESSION bronze.compression_codec = 'ZSTD';
CREATE SCHEMA IF NOT EXISTS bronze.q10;
CREATE TABLE bronze.q10.nation   WITH (format = 'PARQUET') AS SELECT * FROM tpch.sf1.nation;
CREATE TABLE bronze.q10.customer WITH (format = 'PARQUET') AS SELECT * FROM tpch.sf1.customer;
CREATE TABLE bronze.q10.orders   WITH (format = 'PARQUET') AS SELECT * FROM tpch.sf1.orders;
CREATE TABLE bronze.q10.lineitem WITH (format = 'PARQUET') AS SELECT * FROM tpch.sf1.lineitem;
