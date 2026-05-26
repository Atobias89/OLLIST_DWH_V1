{{
    config(
        materialized = 'incremental',
        unique_key = 'customer_unique_id',
        incremental_strategy = 'delete+insert',
        merge_exclude_columns = ['created_at','customer_unique_id'],
        on_schema_change ='append_new_columns'
    )
}}




WITH customers AS(
    select 
        customer_unique_id,
        customer_zip_code_prefix,
        customer_id,
        cast(now() as date) as created_at,
        cast(now() as date) as updated_at
    from {{source('olt','olist_customers_dataset')}}
)


SELECT 
    customer_unique_id,
    customer_zip_code_prefix,
    customer_id,
    created_at,
    updated_at
FROM customers

{% if is_incremental() %}
    WHERE updated_at > (SELECT coalesce(MAX(updated_at), '1900-01-01') FROM {{this}})
{% endif %}

