{{
    config(
        materialized = 'incremental',
        unique_key = ['id_dim_order_detail','id_dim_product', 'id_dim_customers', 'id_dim_sellers'],
        merge_strategy = 'merge',
        merge_exclude_columns = ['created_at'],
        on_schema_change = 'append_new_columns'
    )
}}



With orders as (
   Select
      int_order.id_dim_order_detail,
      int_order.order_id,
      int_order.total_order_value,
      int_order.Order_date

   From {{ref('int_order_detail')}} as int_order
   inner join {{ref('dim_order_detail')}} as dim_ord on dim_ord.id_dim_order_detail = int_order.id_dim_order_detail
),

cust as (
 Select 
  int_cust.id_dim_customers,
  int_cust.order_id
 From  {{ref('int_customers')}} int_cust
 inner join {{ref('dim_customers')}} dim_cus on int_cust.id_dim_customers = dim_cus.id_dim_customers
),


sel as (
  Select 
   int_s.id_dim_sellers,
   int_s.order_id
  From  {{ref('int_sellers')}} int_s
  inner join {{ref('dim_sellers')}} dim_sel on int_s.id_dim_sellers = dim_sel.id_dim_sellers
),
pro as (
  Select 
   int_p.id_dim_product,
   int_p.order_id
  From  {{ref('int_products')}} int_p
  inner join {{ref('dim_products')}} dim_pro on int_p.id_dim_product = dim_pro.id_dim_product 
),

 fact_orders as (
 select 
    orders.id_dim_order_detail,
    cust.id_dim_customers,
    pro.id_dim_product,
    sel.id_dim_sellers,
    dates_order_detail.ID_DATE,
    cast(count(id_dim_customers) as Integer) as purchase_number,
    sum(orders.total_order_value) as total_order_value,
    CAST(now() as date) as created_at, 
    CAST(now() as date) as updated_at     
 from orders 
 inner join  cust on orders.order_id = cust.order_id
 inner join sel on sel.order_id = orders.order_id
 inner join pro on orders.order_id = pro.order_id
 inner join {{ref('dim_dates')}} as dates_order_detail on  DATE(orders.Order_date) = DATE(dates_order_detail.date) 

 group by orders.id_dim_order_detail,
    cust.id_dim_customers,
    pro.id_dim_product,
    sel.id_dim_sellers,
    dates_order_detail.ID_DATE

)



select 
   id_dim_order_detail,
   id_dim_customers,
   id_dim_product,
   id_dim_sellers,
   ID_DATE,
   purchase_number,
   total_order_value,
   created_at, 
   updated_at   
 from fact_orders

 {% if is_incremental() %}
    WHERE updated_at > (SELECT coalesce(Max(updated_at),'1900-01-01') from {{this}})
{% endif %}