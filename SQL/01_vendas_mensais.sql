WITH vendas_mensais AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS mes,
        COUNT(DISTINCT o.order_id)                    AS pedidos,
        ROUND(SUM(oi.price), 2)                       AS receita
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY mes
)
SELECT
    mes,
    pedidos,
    receita,
    ROUND(receita / pedidos, 2) AS ticket_medio,
    ROUND(
        100.0 * (receita - LAG(receita) OVER (ORDER BY mes))
        / LAG(receita) OVER (ORDER BY mes), 1
    ) AS crescimento_pct
FROM vendas_mensais
ORDER BY mes;