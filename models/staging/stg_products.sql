
{{
    config(
        materialized = 'incremental',
        unique_key = ['product_id'],
        incremental_strategy = 'merge',
        merge_exclude_columns = ['created_at']

    )
}}


With products as (
    select distinct 
        product_id, 
        product_category_name,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm,
        cast(now() as date) as created_at,
        cast (now() as date) as updated_at  
    from {{source('olt','olist_products_dataset')}}
    where product_category_name is not null

)

select 
    product_id, 
    product_category_name,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    created_at,
    updated_at   
From products

{% if is_incremental() %}
    WHERE updated_at > (SELECT coalesce(MAX(updated_at), '1900-01-01') FROM {{this}})
{% endif %}
