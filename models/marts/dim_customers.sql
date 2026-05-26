

{{
    config(
        materialized = 'incremental',
        unique_key = ['id_dim_customers'],
        incremental_strategy = 'merge',
        merge_exclude_columns = ['created_at'],
        on_schema_change='append_new_columns'
    )
}}


with ctm as (
    select 
        stg_cus.customer_unique_id,
        stg_cus.customer_zip_code_prefix,
        stg_cus.customer_id,
        cast(now() as date) as created_at,
        cast(now() as date) as updated_at
    from {{ref('stg_customers')}} stg_cus
    inner join {{ref('stg_geolocation')}} as stg_geo on stg_geo.geolocation_zip_code_prefix = stg_cus.customer_zip_code_prefix 
   
    
)




select
    {{dbt_utils.generate_surrogate_key(['customer_unique_id','customer_id'])}} as id_dim_customers,
    customer_unique_id,
    {{dbt_utils.generate_surrogate_key(['customer_zip_code_prefix'])}} as zip_code_prefix_id,  
    customer_id,
    created_at,
    updated_at
from ctm

{% if is_incremental() %}
  where updated_at > (SELECT coalesce(MAX(updated_at),'1900-01-01') FROM {{this}})
{% endif %}
