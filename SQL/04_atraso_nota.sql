WITH entregas AS (
    SELECT
        order_id,
        julianday(date(order_delivered_customer_date))
            - julianday(date(order_estimated_delivery_date)) AS dias_vs_estimado
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
),
nota_pedido AS (
    SELECT order_id, AVG(review_score) AS nota
    FROM order_reviews
    GROUP BY order_id
),
base AS (
    SELECT
        e.order_id,
        n.nota,
        CASE
            WHEN e.dias_vs_estimado < 0  THEN '1. Antes do prazo'
            WHEN e.dias_vs_estimado = 0  THEN '2. No dia estimado'
            WHEN e.dias_vs_estimado <= 3 THEN '3. Atraso 1-3 dias'
            WHEN e.dias_vs_estimado <= 7 THEN '4. Atraso 4-7 dias'
            ELSE                              '5. Atraso 8+ dias'
        END AS faixa
    FROM entregas e
    JOIN nota_pedido n ON n.order_id = e.order_id
)
SELECT
    faixa,
    COUNT(*)                                              AS pedidos,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)    AS pct_pedidos,
    ROUND(AVG(nota), 2)                                   AS nota_media,
    ROUND(100.0 * SUM(CASE WHEN nota <= 2 THEN 1 ELSE 0 END)
          / COUNT(*), 1)                                  AS pct_nota_baixa
FROM base
GROUP BY faixa
ORDER BY faixa;