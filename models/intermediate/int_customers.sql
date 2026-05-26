

With Customers as (
   select
    stg_or.order_id,
    stg_c.customer_unique_id,
    stg_c.customer_zip_code_prefix,
    stg_c.customer_id 
   from {{ref('stg_orders')}} as stg_or 
   inner join {{ref('stg_customers')}} as stg_c on  stg_or.customer_id = stg_c.customer_id 
   inner join {{ref('stg_geolocation')}} as stg_geo on stg_geo.geolocation_zip_code_prefix = stg_c.customer_zip_code_prefix 
)




select 
   {{dbt_utils.generate_surrogate_key(['customer_unique_id ','customer_id'])}} as id_dim_customers,
   * 
from Customers

