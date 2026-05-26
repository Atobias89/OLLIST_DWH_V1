/*
select 
    {{dbt_utils.generate_surrogate_key(['order_id'])}} as id_dim_order_detail,
    order_id,
    product_id ,
    product_category_name,
    Order_date,
    order_status 
 from {{ref('int_order_detail')}} */

{{
   config(
      materialized = 'incremental',
      unique_key = ['id_dim_order_detail'],
      incremental_strategy = 'merge',
      exclude_merge_columns = ['created_at'],
      on_schema_change = 'append_new_columns'
   )
}}

 With order_det As (
   select   
       stg_or.order_id,    
      concat(extract(Hour from  stg_or.order_purchase_timestamp ),':',extract(Minute from  stg_or.order_purchase_timestamp ),':',extract( second from   stg_or.order_purchase_timestamp)) as purchase_time,
      stg_or.order_status,      
      stg_or.payment_type,     
      stg_or.payment_value,
      cast(now() as date) as created_at,
      cast(now() as date) as updated_at
   from {{ref('stg_products')}} as stg_pro
   inner join {{ref('stg_order_items')}} as stg_oi on stg_oi.product_id = stg_pro.product_id
   inner join {{ref('stg_orders')}} as stg_or on stg_or.order_id = stg_oi.order_id   
   group by stg_or.order_id,       
       purchase_time,
      stg_or.order_status,      
      stg_or.payment_type,     
      stg_or.payment_value
   
 
)

select 
   {{dbt_utils.generate_surrogate_key(['order_id','payment_type'])}} as id_dim_order_detail,
   order_id,      
   purchase_time,
   order_status,      
   payment_type,     
   payment_value,
   created_at,
   updated_at
from order_det

{% if is_incremental() %}
  where updated_at > (SELECT coalesce(MAX(updated_at),'1900-01-01') FROM {{this}})
{% endif %}
