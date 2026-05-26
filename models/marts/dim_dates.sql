WITH date_spin  AS (
    {{dbt_utils.date_spine(
        start_date = "to_date('01/01/2015','dd/mm/yyyy')",
        datepart = "day",
        end_date = "to_date('31/12/2030','dd/mm/yyyy')"
    )

    }}
), 


calculated as (
    SELECT
        TO_CHAR(date_day, 'YYYYMMDD')  AS ID_DATE,         
        date_day AS DATE,
        cast(EXTRACT(YEAR from date_day) as integer) AS ANNEE,

         CASE
            WHEN EXTRACT(YEAR from date_day) % 4 = 0 AND (EXTRACT(YEAR from date_day) % 100 <> 0 OR EXTRACT(YEAR from date_day) = 400) then 'OUI'
            ELSE 'NON'
        END AS ESTBISSEXTILE,
           CASE 
            WHEN EXTRACT(MONTH from date_day) <= 6 THEN 1
            ELSE 2
        END AS SEMESTRE,
        cast (EXTRACT(QUARTER FROM date_day) as integer) AS TRIMESTRE,     
        cast (EXTRACT(MONTH from date_day)   as integer) AS MOIS,
        cast (EXTRACT(DAY from date_day)     as integer) AS JOUR, 
        cast (EXTRACT(DOY FROM date_day)     as integer) AS NOMBREJOURANNEE,         
        cast (EXTRACT(DOW FROM date_day)     as integer) AS NOMBREJOURSEMAINE,
        CASE 
            WHEN EXTRACT(DOW FROM date_day) = 1 THEN
                'LUNDI'
            WHEN EXTRACT(DOW FROM date_day) = 2 THEN
                'MARDI'
            WHEN EXTRACT(DOW FROM date_day) = 3 THEN
                'MERCREDI'
            WHEN EXTRACT(DOW FROM date_day) = 4 THEN
                'JEUDI'
            WHEN EXTRACT(DOW FROM date_day) = 5 THEN
                'VENDREDI'
            WHEN EXTRACT(DOW FROM date_day) = 6 THEN
                'SAMEDI'
            ELSE 
                'DIMANCHE'
        END AS JOURSEMAINE

    FROM date_spin    
)

select * from calculated