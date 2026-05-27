
{{config(
    materialized = 'incremental',
    unique_key = ['id_dim_product'],
    incremental_strategy = 'merge',    
    merge_exclude_columns = ['created_at'],
    on_schema_change = 'append_new_columns'
)

}}


with products as (
    select       
        product_id, 
        product_category_name,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm,
        cast(now() as date) as created_at,
        cast(now() as date) as updated_at 
    from 
    {{ref('stg_products')}}
)

select
        {{dbt_utils.generate_surrogate_key(['product_id','product_category_name'])}} as id_dim_product,
        product_id, 
        product_category_name,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm,
        created_at,
       updated_at 
from  products

{% if is_incremental() %}
    WHERE updated_at > (SELECT coalesce(Max(updated_at),'1900-01-01') from {{this}})
{% endif %}