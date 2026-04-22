-- ============================================================
-- FILE: 01_exploratory_analysis.sql
-- PROJECT: Olist Brazilian E-Commerce (2016–2018)
-- BUSINESS QUESTION: Why do customers leave bad reviews?
-- DESCRIPTION: High-level overview of review score distribution
-- ============================================================


-- [1] Total number of reviews
SELECT
    COUNT(review_score) AS total_reviews
FROM public.order_reviews;


-- [2] Total bad reviews (1–2 stars)
SELECT
    COUNT(review_score) AS bad_reviews
FROM public.order_reviews
WHERE review_score IN (1, 2);


-- [3] Review distribution by score
-- Insight: Understand the spread — how many customers are unhappy vs satisfied?
SELECT
    review_score,
    COUNT(review_score)                                    AS numb_reviews,
    ROUND(COUNT(review_score) * 100.0 / SUM(COUNT(review_score)) OVER (), 2) AS percentage
FROM public.order_reviews
GROUP BY review_score
ORDER BY review_score;


-- [4] Bad review volume by year
-- Insight: Is the number of bad reviews growing over time?
SELECT
    EXTRACT(YEAR FROM review_creation_date) AS year,
    COUNT(review_score)                     AS bad_reviews
FROM public.order_reviews
WHERE review_score IN (1, 2)
GROUP BY year
ORDER BY year;


-- [5] Total orders by year
-- Insight: Volume growth context — more orders naturally means more bad reviews
SELECT
    EXTRACT(YEAR FROM review_creation_date) AS year,
    COUNT(order_id)                         AS total_orders
FROM public.order_reviews
GROUP BY year
ORDER BY year;


-- [6] Bad reviews with and without written comments, by year
-- Insight: How many unhappy customers bother to explain why?
SELECT
    EXTRACT(YEAR FROM review_creation_date) AS year,
    COUNT(review_score) FILTER (WHERE review_comment_message IS NULL
        AND review_score IN (1, 2))         AS bad_review_no_comment,
    COUNT(review_score) FILTER (WHERE review_comment_message IS NOT NULL
        AND review_score IN (1, 2))         AS bad_review_with_comment
FROM public.order_reviews
GROUP BY year
ORDER BY year;
