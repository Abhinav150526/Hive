
-- 1.3 Hive Data Models

-- Create a Database
CREATE DATABASE IF NOT EXISTS example_db;

-- Create a Managed Table
CREATE TABLE IF NOT EXISTS example_table (
    id INT,
    name STRING,
    age INT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Create an External Table
CREATE EXTERNAL TABLE IF NOT EXISTS external_table (
    id INT,
    name STRING,
    salary FLOAT
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/user/hive/external_data/';

-- Partitioning Example
CREATE TABLE IF NOT EXISTS sales_data (
    sale_id INT,
    product_name STRING,
    price FLOAT
) PARTITIONED BY (sale_date STRING);

-- Bucketing Example
CREATE TABLE IF NOT EXISTS bucketed_table (
    user_id INT,
    user_name STRING
) CLUSTERED BY (user_id) INTO 4 BUCKETS;

-- ORC Format Table
CREATE TABLE IF NOT EXISTS orc_table (
    id INT,
    name STRING
) STORED AS ORC;

-- 1.4 Hive Query Language (HiveQL)

-- Select Query
SELECT * FROM example_table WHERE age > 30;

-- Insert Data into Table
INSERT INTO example_table (id, name, age) VALUES (1, 'Alice', 29);

-- Update Data (for ACID table)
UPDATE example_table SET age = 30 WHERE name = 'Alice';

-- Delete Data (for ACID table)
DELETE FROM example_table WHERE age < 25;

-- Aggregate Query (Group By)
SELECT age, COUNT(*) FROM example_table GROUP BY age;

-- Join Query
SELECT t1.name, t2.salary 
FROM example_table t1 
JOIN external_table t2 ON t1.id = t2.id;

-- Window Function
SELECT name, 
       age, 
       ROW_NUMBER() OVER (PARTITION BY age ORDER BY id) AS row_num 
FROM example_table;

-- 1.5 Data Loading in Hive

-- Load Data from HDFS
LOAD DATA INPATH '/user/hive/input/file.txt' INTO TABLE example_table;

-- Load Data from Local File
LOAD DATA LOCAL INPATH '/home/user/data/file.txt' INTO TABLE example_table;

-- 1.6 Partitioning and Bucketing

-- Static Partitioning
INSERT INTO sales_data PARTITION (sale_date='2023-01-01') VALUES (101, 'Laptop', 999.99);

-- Dynamic Partitioning
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

INSERT INTO sales_data PARTITION (sale_date) 
SELECT sale_id, product_name, price, sale_date 
FROM temp_sales_data;

-- Bucketing
INSERT INTO TABLE bucketed_table 
SELECT user_id, user_name 
FROM users_data 
CLUSTER BY user_id;

-- 1.7 Optimization Techniques

-- Partition Pruning
SELECT * FROM sales_data WHERE sale_date = '2023-01-01';

-- Predicate Pushdown
SELECT * FROM external_table WHERE salary > 50000;

-- Vectorized Query Execution (Using ORC format)
SET hive.vectorized.execution.enabled = true;
SELECT * FROM orc_table WHERE id > 10;

-- 1.8 Hive Performance Tuning

-- Map Join
SET hive.auto.convert.join = true;
SELECT /*+ MAPJOIN(small_table) */ large_table.name, small_table.category
FROM large_table
JOIN small_table ON large_table.id = small_table.id;

-- Parallel Execution
SET hive.exec.parallel = true;

-- Compression Techniques
SET mapreduce.output.fileoutputformat.compress = true;
SET mapreduce.output.fileoutputformat.compress.codec = org.apache.hadoop.io.compress.SnappyCodec;

-- 1.9 Advanced Features

-- Insert with ACID
INSERT INTO example_table VALUES (2, 'Bob', 35);

-- Update with ACID
UPDATE example_table SET name = 'Charlie' WHERE id = 2;

-- User-Defined Function (UDF) Usage
CREATE TEMPORARY FUNCTION my_upper AS 'org.apache.hadoop.hive.ql.udf.generic.GenericUDFUpperCase';
SELECT my_upper(name) FROM example_table;

-- 1.10 Hive on Spark/Tez/LLAP

-- Run Hive Query on Tez Engine
SET hive.execution.engine=tez;
SELECT * FROM example_table;

-- Run Hive Query on Spark Engine
SET hive.execution.engine=spark;
SELECT * FROM example_table;
