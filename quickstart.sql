-- 1. Create Database & Schema
CREATE OR REPLACE DATABASE TEST_DBT_ENV;
CREATE OR REPLACE SCHEMA TEST_DBT_ENV.PUBLIC;

USE DATABASE TEST_DBT_ENV;
USE SCHEMA TEST_DBT_ENV.PUBLIC;

-- 2. Define the SNOW_FAKER Python UDF
CREATE OR REPLACE FUNCTION SNOW_FAKER(property VARCHAR)
  RETURNS VARCHAR
  LANGUAGE PYTHON
  RUNTIME_VERSION = '3.10'
  PACKAGES = ('Faker')
  HANDLER = 'execute'
AS
$$
from faker import Faker
def execute(property):
    fake = Faker()
    prop = str(property).lower().strip()
    fake_prop = [str(x) for x in dir(fake) if not x.startswith('_')]
    if prop not in fake_prop:
        raise ValueError(f"Invalid fake property: {property}")
    return str(getattr(fake, prop)())
$$;

-- 3. Create Base Tables
CREATE OR REPLACE TABLE customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY SEQ4()) AS customer_id,
    SNOW_FAKER('first_name') AS first_name, 
    SNOW_FAKER('last_name') AS last_name, 
    SNOW_FAKER('date_of_birth') AS dob, 
    SNOW_FAKER('address') AS address, 
    SNOW_FAKER('zipcode') AS zipcode, 
    CURRENT_TIMESTAMP AS refreshed_at
FROM TABLE(GENERATOR(ROWCOUNT => 10));

CREATE OR REPLACE TABLE orders AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY SEQ4()) AS order_id,
    UNIFORM(1, 10, RANDOM())::INT AS customer_id,
    CURRENT_DATE - UNIFORM(1, 365, RANDOM())::INT AS order_date,
    UNIFORM(10, 500, RANDOM()) AS amount,
    SNOW_FAKER('city') AS shipping_city,
    CURRENT_TIMESTAMP AS refreshed_at
FROM TABLE(GENERATOR(ROWCOUNT => 20));

-- 4. Validate
SELECT * FROM customers LIMIT 5;
SELECT * FROM orders LIMIT 5;

-- 5. Lineage Test: join customers ↔ orders
SELECT c.customer_id, c.first_name, c.last_name, o.order_id, o.amount, o.order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LIMIT 10;
