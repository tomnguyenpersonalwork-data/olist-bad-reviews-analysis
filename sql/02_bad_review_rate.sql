-- ============================================================
-- FILE: 02_bad_review_rate.sql
-- PROJECT: Olist Brazilian E-Commerce (2016–2018)
-- BUSINESS QUESTION: Why do customers leave bad reviews?
-- DESCRIPTION: Bad review rate trend over time (monthly & yearly)
-- ============================================================


-- [1] Yearly summary: total reviews vs bad reviews vs bad review rate
-- Insight: Is the proportion of bad reviews increasing as Olist scales?
SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp)                           AS year,
    COUNT(DISTINCT o.order_id)                                              AS total_orders,
    COUNT(r.review_id)                                                      AS total_reviews,
    COUNT(r.review_id) FILTER (WHERE r.review_score IN (1, 2))             AS bad_reviews,
    ROUND(
        COUNT(r.review_id) FILTER (WHERE r.review_score IN (1, 2)) * 100.0
        / NULLIF(COUNT(r.review_id), 0), 2
    )                                                                       AS bad_review_rate
FROM orders o
LEFT JOIN order_reviews r ON r.order_id = o.order_id
GROUP BY year
ORDER BY year;


-- [2] Monthly bad review rate (2017–2018)
-- Insight: Are there seasonal spikes in bad reviews?
-- Note: Grouped by purchase date, not review date.
--       Reason: bad reviews are a lagging outcome — the root cause
--       (late delivery, stock-out) happens at purchase/fulfillment time.
--       Using review_date would misattribute Dec orders reviewed in Jan.
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date                  AS purchase_month,
    COUNT(DISTINCT o.order_id)                                             AS total_orders,
    COUNT(r.review_id)                                                     AS total_reviews,
    COUNT(*) FILTER (WHERE r.review_score <= 2)                            AS bad_reviews,
    ROUND(
        COUNT(*) FILTER (WHERE r.review_score <= 2)::numeric
        / NULLIF(COUNT(r.review_id), 0) * 100, 2
    )                                                                      AS bad_review_rate
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp <  '2018-09-01'
GROUP BY purchase_month
ORDER BY purchase_month;
