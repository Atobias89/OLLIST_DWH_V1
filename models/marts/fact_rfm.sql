{{config(
    materialized  = 'incremental',
    unique_key = ['id_dim_customers'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['created_at']
)}}


WITH source AS (
    select 
        id_dim_customers,
        max(int_dd.Order_date) as last_order,
        count(distinct int_dd.order_id) as frequency,
        sum(int_dd.total_order_value) as monetary
        from {{ref('int_order_detail')}} as  int_dd
        inner join {{ref('int_customers')}} as int_cus on int_cus.order_id = int_dd.order_id
        group by  id_dim_customers
),

rfm as (
    SELECT
    id_dim_customers,
    DATE_PART('day', CAST('2018-10-31 00:00:00' AS TIMESTAMP) -  COALESCE(CAST(last_order AS TIMESTAMP), NULL) )      AS recency,
    frequency,
    monetary
FROM source    
),

score AS(
    SELECT
        id_dim_customers, 
        recency, 
        frequency, 
        monetary, 
        NTILE(5) OVER(ORDER BY recency DESC) AS r_score, 
        NTILE(5) OVER(ORDER BY frequency) AS f_score, 
        NTILE(5) OVER(ORDER BY monetary) AS m_score
    FROM rfm
),

segmentation AS (
    SELECT
    id_dim_customers, 
    recency, 
    frequency, 
    monetary, 
    r_score, 
    f_score, 
    m_score, 
    CONCAT(CAST(r_score AS text), CAST(f_score AS text), CAST(m_score AS text)) AS rfm_score,
     CAST(now() as date) as created_at, 
    CAST(now() as date) as updated_at
    FROM score
)

SELECT
    id_dim_customers, 
    recency, 
    frequency, 
    monetary, 
    r_score, 
    f_score, 
    m_score, 
    rfm_score, 
    CASE
        WHEN rfm_score IN ('555', '554', '545', '455') THEN 'Top Customers'
        WHEN rfm_score LIKE '5__' THEN 'Loyal Customers'
        WHEN rfm_score LIKE '__5' THEN 'Big Spenders'
        WHEN rfm_score LIKE '_5_' THEN 'Frequent Buyers'
        WHEN rfm_score IN ('111', '112', '121') THEN 'Lost Customers'
        ELSE 'Average Customers'
    END AS customer_segment,
    created_at, 
    updated_at
FROM segmentation


{% if is_incremental() %}
    WHERE updated_at > (SELECT coalesce(Max(updated_at),'1900-01-01') from {{this}})
{% endif %}