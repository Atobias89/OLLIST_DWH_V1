{{
    config(
        materialized = 'incremental',
        unique_key = ['seller_id'],
        incremental_strategy = 'merge',
        merge_exclude_columns = ['created_at']
    )
}}

WITH sellers_dataset AS (
    SELECT 
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state,
        cast(now() as date) as created_at,
        cast(now() as date) as updated_at
    FROM {{source('olt','olist_sellers_dataset')}}
)

SELECT 
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    created_at,
    updated_at
FROM sellers_dataset

{% if is_incremental() %}
    WHERE updated_at > (SELECT coalesce(MAX(updated_at), '1900-01-01') FROM {{this}})
{% endif %}
