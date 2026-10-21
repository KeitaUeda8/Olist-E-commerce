WITH pedido_categoria AS (
    SELECT
        oi.order_id,
        COALESCE(t.product_category_name_english,
                 p.product_category_name,
                 'unknown')                 AS categoria,
        SUM(oi.price)                       AS receita
    FROM order_items oi
    JOIN orders o   ON o.order_id = oi.order_id
    JOIN products p ON p.product_id = oi.product_id
    LEFT JOIN product_category_name_translation t
           ON t.product_category_name = p.product_category_name
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY oi.order_id, categoria
),
nota_pedido AS (
    SELECT order_id, AVG(review_score) AS nota
    FROM order_reviews
    GROUP BY order_id
),
por_categoria AS (
    SELECT
        pc.categoria,
        COUNT(*)                      AS pedidos,
        ROUND(SUM(pc.receita), 2)     AS receita,
        ROUND(AVG(np.nota), 2)        AS nota_media
    FROM pedido_categoria pc
    LEFT JOIN nota_pedido np ON np.order_id = pc.order_id
    GROUP BY pc.categoria
)
SELECT
    categoria,
    pedidos,
    receita,
    ROUND(100.0 * receita / SUM(receita) OVER (), 1) AS pct_receita,
    nota_media,
    RANK() OVER (ORDER BY receita DESC)              AS rank_receita,
    CASE WHEN pedidos >= 100
         THEN RANK() OVER (PARTITION BY (pedidos >= 100)
                           ORDER BY nota_media ASC)
    END                                              AS rank_pior_nota
FROM por_categoria
ORDER BY receita DESC;

