

With order_detail As (
   select
      stg_pro.product_id, 
      stg_pro.product_category_name,
      stg_pro.product_weight_g,
      stg_pro.product_length_cm,
      stg_pro.product_height_cm,
      stg_pro.product_width_cm,    
      stg_oi.order_id      
   from {{ref('stg_products')}} as stg_pro
   inner join {{ref('stg_order_items')}} as stg_oi on stg_oi.product_id = stg_pro.product_id
   
  
)

select 
   {{dbt_utils.generate_surrogate_key(['product_id'])}} as id_dim_product,
   * 
from order_detail