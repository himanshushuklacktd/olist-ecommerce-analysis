use olist_db;

-- Total Revenue
SELECT
  ROUND(SUM(payment_value), 2) AS total_revenue
FROM payments;

-- Total Delivered Orders
SELECT
  COUNT(*) AS total_orders
FROM orders_cleaned;

-- Monthly Revenue Trend
SELECT
  oc.order_month,
  ROUND(SUM(p.payment_value), 2) AS monthly_revenue
FROM orders_cleaned oc
JOIN payments p ON oc.order_id = p.order_id
GROUP BY oc.order_month
ORDER BY oc.order_month;