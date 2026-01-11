{{
config(
materialized='view',
alias='mart_orders_dynamics'
)
}}
SELECT 
    (DATE_TRUNC('week', so.order_date) + INTERVAL '6 days')::DATE AS date_week_interval,
        COUNT(*) AS total_orders                       
FROM 
{{ref('hub_order')}} as ho
JOIN {{ref('sat_order')}} as so on so.order_pk=ho.order_pk
GROUP BY 
    (DATE_TRUNC('week', so.order_date) + INTERVAL '6 days')::DATE              
ORDER BY 
    date_week_interval
