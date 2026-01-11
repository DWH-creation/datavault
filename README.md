## Configure environment

1. Install prerequisites:
    - IDE (e.g. [VS Code](https://code.visualstudio.com/docs/setup/setup-overview))
    - [Docker](https://docs.docker.com/engine/install/)

1. Fork & Clone this repository and open in IDE

1. Spin up Docker containers

    All the services are configured via [Docker containers](./docker-compose.yml).

    - devcontainer
    - Postgres

    ```bash
    # build dev container
    devcontainer build .

    # open dev container
    devcontainer open .
    ```

    ![](./docs/1_docker_compose_services.png)

1. Verify you are in a development container by running commands:

    ```bash
    dbt --version
    ```

    ![](./docs/2_dbt_version.png)

    If any of these commands fails printing out used software version then you are probably running it on your local machine not in a dev container!


## Install dbt packages

1. Install modules via [packages.yml](./packages.yml)

    ```bash
    dbt clean # clean temp files
    dbt deps # install dependencies (modules)
    ```


## Homework

1. Build a data mart over Data Vault.

Dynamics of changes in the number of orders by calendar week and order status.

Добавила в source_orders.csv строку с новым бизнес-ключом. 
В представлении stg_orders появилась новая строка с бизнес-ключом.
В таблице hub_orders автоматически сгенерировалась строка с новым ключом order_pk. 

Добавила в source_orders.csv строку с существующим бизнес-ключом, но с другими свойствами.
В представлении stg_orders появилась новая строка с существующим бизнес-ключом.
В таблице hub_order ничего не изменилось, так как хэш-ключ уже ранее был сгенерирован под заданный бизнес-ключ.
В таблице sat_order появилась новая строка с повторяющимся хэш-ключом, но разным хашдифф.

Удалила строку из файла  source_orders.csv.
Строка удалилась из всех таблиц, кроме hub_order.

Витрина с понедельной динамикой заказов.
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

Витрина с сотрировкой клиентов по количеству заказов.
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
В таблице sat_order сгенерировался order_hushdiff. 

