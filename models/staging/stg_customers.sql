{{ config(materialized='table') }}

with source as (
    select * from {{ source('raw', 'customers') }}
),
renamed as (
    select
        customer_id,
        first_name,
        last_name,
        dob,
        address,
        zipcode,
        refreshed_at
    from source
)
select * from renamed
