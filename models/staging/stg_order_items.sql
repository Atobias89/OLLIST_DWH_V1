{{
    config(
        materialized = 'incremental',
        unique_key = ['order_id'],
        incremental_strategy = 'delete+insert',
        merge_exclude_columns = ['created_at','order_id']
    )
}}

With items as (
    select distinct
    order_id,
    product_id,
    seller_id,
    price,
    shipping_limit_date,
    cast(now() as date ) as created_at,
    cast(now() as date ) as updated_at
    from {{source('olt','olist_order_items_dataset')}}
    
)


select
   order_id,
    product_id,
    seller_id,
    price,
    shipping_limit_date,
    created_at,
    updated_at
from items

{% if is_incremental() %}
  WHERE updated_at > (select coalesce(MAX(updated_at),'1900-01-01') from {{this}})
{% endif  %}