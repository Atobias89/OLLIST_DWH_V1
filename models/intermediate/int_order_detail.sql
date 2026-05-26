

With order_detail As (
   select   
      stg_or.order_id, 
      stg_or.order_purchase_timestamp as Order_date,
      stg_or.order_status,
      stg_or.payment_type,     

      stg_oi.price as total_order_value
   from {{ref('stg_order_items')}} as stg_oi
   inner join {{ref('stg_orders')}} as stg_or on stg_or.order_id = stg_oi.order_id
  
)

select 
   {{dbt_utils.generate_surrogate_key(['order_id','payment_type'])}} as id_dim_order_detail,
    order_id, 
      Order_date,
     order_status,
     total_order_value
from order_detail