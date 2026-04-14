-- Month on Month Revenue Growth
WITH monthly AS (
  SELECT
    oc.order_month,
    ROUND(SUM(p.payment_value), 2) AS revenue
  FROM orders_cleaned oc
  JOIN payments p ON oc.order_id = p.order_id
  GROUP BY oc.order_month
)
SELECT
  order_month,
  revenue,
  LAG(revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
  ROUND(
    (revenue - LAG(revenue) OVER (ORDER BY order_month)) * 100.0 /
    LAG(revenue) OVER (ORDER BY order_month), 2
  ) AS mom_growth_pct
FROM monthly
ORDER BY order_month;

## LAG() looks at the previous row to calculate growth %
## This shows which months had the biggest jumps


-- Top 10 Sellers Ranked by Revenue
WITH seller_revenue AS (
  SELECT
    oi.seller_id,
    s.seller_state,
    ROUND(SUM(p.payment_value), 2) AS total_revenue,
    COUNT(DISTINCT oc.order_id) AS total_orders
  FROM orders_cleaned oc
  JOIN order_items oi ON oc.order_id = oi.order_id
  JOIN payments p ON oc.order_id = p.order_id
  JOIN sellers s ON oi.seller_id = s.seller_id
  GROUP BY oi.seller_id, s.seller_state
)
SELECT
  RANK() OVER (ORDER BY total_revenue DESC) AS seller_rank,
  seller_id,
  seller_state,
  total_revenue,
  total_orders
FROM seller_revenue
LIMIT 10;


## RANK() automatically numbers sellers 1 to 10 by revenue


