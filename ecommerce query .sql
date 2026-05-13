
-- 1. weekday vs weekend (order_purchase_timestamp) payment statistics. 
SELECT 
    CASE 
        WHEN DAYOFWEEK(o.order_purchase_timestamp) IN (1,7) 
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    COUNT(o.order_id) AS total_orders,

    SUM(op.payment_value) AS total_payment,

    AVG(op.payment_value) AS avg_payment,

    ROUND(
        SUM(op.payment_value) * 100.0 /
        SUM(SUM(op.payment_value)) OVER (),
        2
    ) AS percentage_of_total_payment

FROM olist_orders_dataset o

JOIN olist_order_payments_dataset op
ON o.order_id = op.order_id

GROUP BY day_type;

-- 2.Number of orders with review score 5 and payment type as credit card.
SELECT COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders_dataset o
JOIN order_reviews r
ON o.order_id = r.order_id
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
WHERE r.review_score = 5
AND p.payment_type = 'credit_card';

-- 3.Avg no of days taken for order delivery custumer date for pet_shop.
SELECT 
AVG(DATEDIFF(o.order_delivered_customer_date,
             o.order_purchase_timestamp)) AS avg_delivery_days
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
ON o.order_id = oi.order_id
JOIN olist_products_dataset p
ON oi.product_id = p.product_id
WHERE p.product_category_name = 'pet_shop';

-- 4.Avg price and payments values for custumers of sao paulo shop

SELECT 
AVG(oi.price) AS avg_product_price,
AVG(op.payment_value) AS avg_payment_value
FROM olist_customers_dataset c
JOIN olist_orders_dataset o 
ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset oi 
ON o.order_id = oi.order_id
JOIN olist_order_payments_dataset op 
ON o.order_id = op.order_id
WHERE c.customer_city = 'sao paulo';

-- 5. Relationship between shipping days (order_delivered_customer_data-order_purchase_timestamp) vs review scores.
SELECT 
r.review_score,
AVG(DATEDIFF(o.order_delivered_customer_date,
             o.order_purchase_timestamp)) AS avg_shipping_days
FROM olist_orders_dataset o
JOIN order_reviews r
ON o.order_id = r.order_id
GROUP BY r.review_score
ORDER BY r.review_score;

-- 6.top 10 products category by orders
SELECT 
    p.product_category_name,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_orders DESC
LIMIT 10;

-- 7. Top 10 cities by Number of Customers/orders
SELECT 
    c.customer_city,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_city
ORDER BY total_orders DESC
LIMIT 10;
 
 -- 8.Month wise by payment values.
SELECT 
    MONTHNAME(o.order_purchase_timestamp) AS month_name,
    SUM(op.payment_value) AS total_payment_value
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset op
    ON o.order_id = op.order_id
GROUP BY month_name
ORDER BY MIN(o.order_purchase_timestamp);