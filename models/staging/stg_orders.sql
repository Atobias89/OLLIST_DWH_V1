
{{
    config(
        materialized = 'incremental',
        unique_key = ['order_id'],
        incremental_strategy = 'delete+insert',
        merge_exclude_columns = ['created_at','order_id']
    )
}}

WITH orders AS (
   select distinct
   order_dat.order_id,
   order_dat.customer_id,
   order_dat.order_status,
   order_dat.order_purchase_timestamp,
   order_pay.payment_type,  
   order_pay.payment_value,
   cast(now() as date) created_at,
   cast(now() as date) updated_at
   from {{source('olt','olist_orders_dataset')}} as order_dat
   left join {{source('olt','olist_order_payments_dataset')}} as order_pay on order_dat.order_id = order_pay.order_id

   
)


SELECT distinct
   order_id,
   customer_id,
   order_status,
   order_purchase_timestamp,
   payment_type,  
   payment_value,
   created_at,
   updated_at 
FROM orders
{% if is_incremental() %}
    WHERE updated_at > (SELECT coalesce(MAX(updated_at), '1900-01-01') FROM {{this}})
{% endif %}

