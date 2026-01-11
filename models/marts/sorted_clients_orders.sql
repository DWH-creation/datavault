{{
config(
materialized='view',
alias='mart_sorted_clients_orders'
)
}}
SELECT 
    t1.customer_pk,            
    t1.customer_key,                    
    COUNT(t4.order_pk) AS completed_orders 
FROM {{ref('hub_customer')}} t1
JOIN {{ref('link_customer_order')}} t2 ON t1.customer_pk = t2.customer_pk  
JOIN {{ref('hub_order')}} t3 ON t2.order_pk = t3.order_pk
JOIN {{ref('sat_order')}} as t4 on t4.order_pk=t3.order_pk  
WHERE 
    t4.status = 'completed'              
GROUP BY 
    t1.customer_pk, t1.customer_key        
ORDER BY 
    completed_orders DESC