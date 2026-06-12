SELECT 
  FORMAT_TIMESTAMP('%Y-%m', created_at) AS month,
  ROUND(SUM(sale_price), 2) AS total_revenue,
  COUNT(DISTINCT order_id) AS total_orders
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE status = 'Complete'
GROUP BY 1
ORDER BY 1 DESC;

WITH CategorySales AS (
  SELECT 
    u.country,
    p.category,
    COUNT(oi.id) AS units_sold,
    DENSE_RANK() OVER (PARTITION BY u.country ORDER BY COUNT(oi.id) DESC) AS category_rank
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.users` u ON oi.user_id = u.id
  JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id
  GROUP BY u.country, p.category
)
SELECT country, category, units_sold
FROM CategorySales
WHERE category_rank <= 5
ORDER BY country ASC, units_sold DESC;
