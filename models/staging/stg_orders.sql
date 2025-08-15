{{ config(materialized='table') }}

with source as (
    select * from {{ source('raw', 'orders') }}
),
renamed as (
    select
        order_id,
        customer_id,
        order_date,
        amount,
        shipping_city,
        refreshed_at
    from source
)
select * from renamed
