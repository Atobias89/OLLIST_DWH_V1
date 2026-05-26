
-- with sellers as (
--     select 
--         ss.seller_id,
--         sg.geolocation_zip_code_prefix ,
--         sg.geolocation_lat, 
-- 	    sg.geolocation_lng,
--         sg.geolocation_city ,
--         sg.geolocation_state 
--     from  ss
--     inner join {{ref('stg_geolocation')}}  sg on sg.geolocation_zip_code_prefix = ss.seller_zip_code_prefix  and sg.geolocation_city = ss.seller_city and sg.geolocation_state = ss.seller_state   
--     group by ss.seller_id,
--         sg.geolocation_zip_code_prefix ,
--          sg.geolocation_lat, 
-- 	    sg.geolocation_lng,
--         sg.geolocation_city ,
--         sg.geolocation_state 
-- )

-- select distinct
--     {{dbt_utils.generate_surrogate_key(['seller_id','geolocation_zip_code_prefix','geolocation_city','geolocation_state'])}} as id_dim_sellers,
--      seller_id,
--      {{dbt_utils.generate_surrogate_key(['geolocation_zip_code_prefix', 'geolocation_lat','geolocation_lng','geolocation_city','geolocation_state'])}} as  seller_zip_code_prefix_id
-- from sellers

{{
    config(
        materialized = 'incremental',
        unique_key = ['id_dim_sellers'],
        merge_strategy = 'merge',
        merge_exclude_columns = ['created_at','id_dim_sellers'],
        merge_update_columns=['seller_city', 'seller_state', 'updated_at'],
        on_schema_change = 'append_new_columns'
    )
}}

WITH sellers AS (
  select distinct    
     seller_id,     
     seller_city ,
     seller_state,
     CAST(now() as date) as created_at, 
     CAST(now() as date) as updated_at 
   from {{ref('stg_sellers')}}
)

select distinct
    {{dbt_utils.generate_surrogate_key(['seller_id'])}} as id_dim_sellers,
     seller_id,     
     seller_city ,
     seller_state,
     created_at, 
     updated_at  
from  sellers
{% if is_incremental() %}
    -- Ne prendre que les sellers qui n'existent pas déjà
    WHERE seller_id NOT IN (SELECT seller_id FROM {{ this }}) OR (seller_city, seller_state) NOT IN (  -- Ou modifiés
            SELECT seller_city, seller_state 
            FROM {{ this }} 
            WHERE seller_id = sellers.seller_id
          )
{% endif %}
-- {% if is_incremental() %}
--     WHERE updated_at > (SELECT coalesce(Max(updated_at),'1900-01-01') from {{this}})
-- {% endif %}