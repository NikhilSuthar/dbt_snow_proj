{{ config(materialized='table') }}

select
    customer_id as cust_id, 
    first_name || ' ' || last_name as full_name,
    dob,
    address,
    zipcode
from {{ ref('stg_customers') }}
