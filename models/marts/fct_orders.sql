{{ config(materialized='table') }}

select
    o.order_id,
    o.customer_id,
    c.full_name,
    o.order_date,
    o.amount,
    o.shipping_city
from {{ ref('stg_orders') }} o
join {{ ref('dim_customers') }} c
    on o.customer_id = c.customer_id
