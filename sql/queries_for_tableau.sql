## Export 1 — Monthly Revenue
SELECT
  oc.order_month,
  ROUND(SUM(p.payment_value), 2) AS monthly_revenue
FROM orders_cleaned oc
JOIN payments p ON oc.order_id = p.order_id
GROUP BY oc.order_month
ORDER BY oc.order_month;

## Export 2 — Revenue by Category
SELECT
  ct.product_category_name_english AS category,
  ROUND(SUM(p.payment_value), 2) AS revenue
FROM orders_cleaned oc
JOIN payments p ON oc.order_id = p.order_id
JOIN order_items oi ON oc.order_id = oi.order_id
JOIN products pr ON oi.product_id = pr.product_id
JOIN category_translation ct
  ON pr.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY revenue DESC
LIMIT 10;

## Export 3 — Orders by State
SELECT
  c.customer_state,
  COUNT(DISTINCT oc.order_id) AS total_orders
FROM orders_cleaned oc
JOIN customers c ON oc.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;

## Export 4 — KPI Summary
SELECT
  ROUND(SUM(p.payment_value), 2) AS total_revenue,
  COUNT(DISTINCT oc.order_id) AS total_orders,
  ROUND(AVG(oc.delivery_time_days), 1) AS avg_delivery_days,
  ROUND(SUM(oc.late_delivery_flag) * 100.0 / COUNT(*), 2) AS late_delivery_pct
FROM orders_cleaned oc
JOIN payments p ON oc.order_id = p.order_id;