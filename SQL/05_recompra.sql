WITH pedidos_cliente AS (
    SELECT
        c.customer_unique_id AS cliente,
        o.order_id
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
por_cliente AS (
    SELECT cliente, COUNT(*) AS pedidos
    FROM pedidos_cliente
    GROUP BY cliente
)
SELECT
    CASE
        WHEN pedidos = 1 THEN '1 pedido'
        WHEN pedidos = 2 THEN '2 pedidos'
        WHEN pedidos = 3 THEN '3 pedidos'
        ELSE                  '4+ pedidos'
    END                                                    AS faixa,
    COUNT(*)                                               AS clientes,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)     AS pct_clientes
FROM por_cliente
GROUP BY faixa
ORDER BY faixa;