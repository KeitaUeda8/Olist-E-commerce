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
pedido_categoria AS (
    SELECT DISTINCT
        oi.order_id,
        COALESCE(t.product_category_name_english,
                 p.product_category_name, 'unknown') AS categoria
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    LEFT JOIN product_category_name_translation t
           ON t.product_category_name = p.product_category_name
)
SELECT
    pc.categoria,
    COUNT(*)                                              AS pedidos,
    ROUND(100.0 * AVG(e.dias_vs_estimado > 0), 1)         AS pct_atraso,
    ROUND(AVG(n.nota), 2)                                 AS nota_media,
    ROUND(AVG(CASE WHEN e.dias_vs_estimado <= 0
                   THEN n.nota END), 2)                   AS nota_no_prazo
FROM entregas e
JOIN nota_pedido n       ON n.order_id = e.order_id
JOIN pedido_categoria pc ON pc.order_id = e.order_id
GROUP BY pc.categoria
HAVING COUNT(*) >= 100
ORDER BY nota_media ASC;