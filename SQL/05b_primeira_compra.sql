WITH pedidos AS (
    SELECT
        c.customer_unique_id AS cliente,
        o.order_id,
        o.order_purchase_timestamp       AS data_compra,
        o.order_status,
        o.order_delivered_customer_date  AS entregue,
        o.order_estimated_delivery_date  AS estimado
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
ranqueado AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY cliente
                           ORDER BY data_compra, order_id) AS n_pedido,
        COUNT(*)     OVER (PARTITION BY cliente)            AS total_pedidos
    FROM pedidos
),
nota_pedido AS (
    SELECT order_id, AVG(review_score) AS nota
    FROM order_reviews
    GROUP BY order_id
)
SELECT
    r.cliente,
    CASE WHEN julianday(date(r.entregue)) - julianday(date(r.estimado)) > 0
         THEN 1 ELSE 0 END                   AS atraso,
    n.nota,
    CASE WHEN r.total_pedidos > 1 THEN 1 ELSE 0 END AS recomprou
FROM ranqueado r
LEFT JOIN nota_pedido n ON n.order_id = r.order_id
WHERE r.n_pedido = 1
  AND r.data_compra >= '2017-01-01'
  AND r.data_compra <  '2018-03-01'
  AND r.order_status = 'delivered'
  AND r.entregue IS NOT NULL;