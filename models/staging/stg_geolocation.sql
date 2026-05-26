{{
    config(
        materialized = 'incremental',
        unique_key = ['geolocation_zip_code_prefix'],
        incremental_strategy = 'merge',
        merge_exclude_columns = ['created_at']
    )
}}

With locat As (
    select distinct
     geolocation_zip_code_prefix,
     geolocation_lat,
     geolocation_lng,
     geolocation_city,
     geolocation_state,
     cast(now() as date) as created_at,
     cast(now() as date) as updated_at
    from {{source('olt','olist_geolocation_dataset')}}
   
)

select 
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    created_at,
    updated_at
from locat

{% if is_incremental() %}
    where updated_at > (SELECT coalesce(MAX(updated_at),'1900-01-01') FROM {{this}})
{% endif %}