WITH entregas AS (
    SELECT
        c.customer_state AS estado,
        julianday(o.order_delivered_customer_date)
            - julianday(o.order_purchase_timestamp)          AS dias_entrega,
        julianday(date(o.order_delivered_customer_date))
            - julianday(date(o.order_estimated_delivery_date)) AS dias_vs_estimado
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
)
SELECT
    estado,
    COUNT(*)                                   AS pedidos,
    ROUND(AVG(dias_entrega), 1)                AS prazo_medio_dias,
    ROUND(AVG(dias_vs_estimado), 1)            AS dias_vs_estimado_medio,
    ROUND(100.0 * SUM(CASE WHEN dias_vs_estimado > 0 THEN 1 ELSE 0 END)
          / COUNT(*), 1)                       AS pct_atraso,
    RANK() OVER (ORDER BY AVG(dias_entrega) DESC) AS rank_prazo
FROM entregas
GROUP BY estado
ORDER BY prazo_medio_dias DESC;
