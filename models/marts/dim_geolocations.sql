
{{
    config(
        materialized = 'incremental',
        unique_key = ['zip_code_prefix_id'],
        incremental_strategy = 'merge',
        merge_exclude_columns = ['created_at'],
        on_schema_change = 'append_new_columns'
    )
}}

WITH geolocation AS (
  SELECT
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state,
        cast(now() as date) as created_at,
        cast(now() as date) as updated_at
  FROM  {{ref('stg_geolocation')}}
)

SELECT
    {{dbt_utils.generate_surrogate_key(['geolocation_zip_code_prefix'])}} as zip_code_prefix_id,
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state,
        created_at,
        updated_at
FROM geolocation

{% if is_incremental() %}
  where updated_at > (SELECT coalesce(MAX(updated_at),'1900-01-01') FROM {{this}})
{% endif %}
