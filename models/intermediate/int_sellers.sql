
with sellers as (
    Select 
        stg_sel.seller_id,
        stg_sel.seller_zip_code_prefix,   
        stg_sel.seller_city ,
        stg_sel.seller_state, 
        stg_or_it.order_id
    from {{ref('stg_sellers')}} as stg_sel
    inner join {{ref('stg_order_items')}} as stg_or_it on stg_or_it.seller_id = stg_sel.seller_id
    inner join {{ref('stg_geolocation')}}  sg on sg.geolocation_zip_code_prefix = stg_sel.seller_zip_code_prefix           
   
)


select 
    {{dbt_utils.generate_surrogate_key(['seller_id','seller_city'])}} as id_dim_sellers,
     *
from sellers