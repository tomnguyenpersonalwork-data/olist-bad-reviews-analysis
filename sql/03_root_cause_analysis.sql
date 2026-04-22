-- ============================================================
-- FILE: 03_root_cause_analysis.sql
-- PROJECT: Olist Brazilian E-Commerce (2016–2018)
-- BUSINESS QUESTION: Why do customers leave bad reviews?
-- DESCRIPTION: Root cause analysis — Late delivery impact + text mining
-- ============================================================


-- [1] Delivery performance overview: late vs early orders
-- Insight: How often does Olist fail to meet its own estimated delivery date?
SELECT
    COUNT(o.order_id) FILTER (WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date) AS late_orders,
    COUNT(o.order_id) FILTER (WHERE o.order_delivered_customer_date < o.order_estimated_delivery_date) AS early_orders
FROM public.orders o
INNER JOIN public.order_reviews r ON o.order_id = r.order_id;


-- [2] Review sentiment when delivery is LATE
-- Insight: Do late deliveries directly cause negative reviews?
SELECT
    EXTRACT(YEAR FROM r.review_creation_date)                               AS year,
    COUNT(r.review_score)                                                   AS total_reviews,
    COUNT(r.review_score) FILTER (WHERE r.review_score IN (3, 4, 5))       AS positive,
    COUNT(r.review_score) FILTER (WHERE r.review_score IN (1, 2))          AS negative,
    ROUND(
        COUNT(r.review_score) FILTER (WHERE r.review_score IN (1, 2)) * 100.0
        / COUNT(r.review_score), 2
    )                                                                       AS negative_rate
FROM public.order_reviews r
INNER JOIN public.orders o ON r.order_id = o.order_id
WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
GROUP BY year
ORDER BY year;


-- [3] Review sentiment when delivery is EARLY
-- Insight: Baseline check — unhappy customers even when delivery is on time?
--          Result: negative rate ~9%, confirming late delivery is a key driver
SELECT
    EXTRACT(YEAR FROM r.review_creation_date)                               AS year,
    COUNT(r.review_score)                                                   AS total_reviews,
    COUNT(r.review_score) FILTER (WHERE r.review_score IN (3, 4, 5))       AS positive,
    COUNT(r.review_score) FILTER (WHERE r.review_score IN (1, 2))          AS negative,
    ROUND(
        COUNT(r.review_score) FILTER (WHERE r.review_score IN (1, 2)) * 100.0
        / COUNT(r.review_score), 2
    )                                                                       AS negative_rate
FROM public.order_reviews r
INNER JOIN public.orders o ON r.order_id = o.order_id
WHERE o.order_delivered_customer_date < o.order_estimated_delivery_date
GROUP BY year
ORDER BY year;


-- [4] What % of bad reviews are caused by late delivery? (by purchase year cohort)
-- Insight: Late delivery consistently accounts for ~30% of all bad reviews
WITH review_stats AS (
    SELECT
        EXTRACT(YEAR FROM o.order_purchase_timestamp)                       AS purchase_year,
        COUNT(o.order_id) FILTER (
            WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
            AND r.review_score IN (1, 2)
        )                                                                   AS late_bad_reviews,
        COUNT(o.order_id) FILTER (
            WHERE r.review_score IN (1, 2)
        )                                                                   AS total_bad_reviews
    FROM public.orders o
    INNER JOIN public.order_reviews r ON o.order_id = r.order_id
    WHERE o.order_delivered_customer_date IS NOT NULL
    GROUP BY purchase_year
)
SELECT
    purchase_year,
    late_bad_reviews,
    total_bad_reviews,
    ROUND(late_bad_reviews * 100.0 / NULLIF(total_bad_reviews, 0), 2)      AS late_bad_percentage
FROM review_stats
ORDER BY purchase_year;


-- [5] Text mining: delivery-related keywords in bad reviews (Portuguese)
-- Keywords: entrega (delivery), atraso (delay), demora (took too long)
-- Insight: Customers explicitly mention delivery issues in their complaints
SELECT
    EXTRACT(YEAR FROM review_creation_date)                                 AS year,
    COUNT(order_id) FILTER (
        WHERE review_score IN (1, 2)
        AND review_comment_message IS NOT NULL
        AND (
            review_comment_message ILIKE '%entrega%'
            OR review_comment_message ILIKE '%atraso%'
            OR review_comment_message ILIKE '%demora%'
        )
    )                                                                       AS delivery_keyword_count
FROM public.order_reviews
GROUP BY year
ORDER BY year;


-- [6] Raw sample: bad reviews mentioning delivery keywords
-- Use case: manual labeling, qualitative validation
SELECT
    r.order_id,
    r.review_score,
    r.review_comment_message
FROM public.order_reviews r
INNER JOIN public.orders o ON r.order_id = o.order_id
WHERE r.review_score IN (1, 2)
  AND r.review_comment_message IS NOT NULL
  AND (
      r.review_comment_message ILIKE '%entrega%'
      OR r.review_comment_message ILIKE '%atraso%'
      OR r.review_comment_message ILIKE '%demora%'
  )
ORDER BY r.review_creation_date DESC;
