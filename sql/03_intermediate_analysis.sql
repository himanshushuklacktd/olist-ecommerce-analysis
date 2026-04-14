-- Revenue by Product Category (Top 10)
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

 ## This becomes our bar chart in Tableau

-- Orders by Customer State
SELECT
  c.customer_state,
  COUNT(DISTINCT oc.order_id) AS total_orders
FROM orders_cleaned oc
JOIN customers c ON oc.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;

##  This becomes our map chart in Tableau




