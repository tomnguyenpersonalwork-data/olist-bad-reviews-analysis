# Olist Bad Reviews Analysis

## Business Question
**Why do customers leave bad reviews on Olist?**

## Dataset
[Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — 2016 to 2018 | ~100K orders | 9 tables | 99,441 unique orders

## Project Structure
```
sql/
├── 01_exploratory_analysis.sql   # Review score distribution & volume trends
├── 02_bad_review_rate.sql        # Bad review rate over time (monthly & yearly)
└── 03_root_cause_analysis.sql    # Late delivery impact + text mining
```

## Key Findings
- **~11% of all reviews are negative** (1–2 stars)
- **Late delivery is the #1 root cause** — accounting for 31.73% of bad reviews
- Customers who receive late orders are significantly more likely to leave negative reviews than on-time deliveries (see 03_root_cause_analysis.sql)
- Text mining on Portuguese comments confirms delivery keywords (*entrega*, *atraso*, *demora*) appear frequently in bad reviews
- Bad review volume grew from 2016 → 2018, but this is partially explained by overall order growth

## Limitations & Assumptions
- Root cause sample: 375 reviews (score ≤ 2), not full dataset of bad reviews
- Manual labels based on review text only — translation via Google Translate (accuracy limitations)
- "Undetermined" (11.47%) = review text insufficient to attribute fault — counted separately, not forced into a category
- Late delivery % cross-validated via both date comparison (~28-32%) and manual sampling — small discrepancy explainable by sample size
  
## Approach
1. Exploratory analysis to size the problem
2. Trend analysis to identify patterns over time
3. Root cause analysis combining quantitative (delivery date comparison) and qualitative (text mining) methods
4. Manual labeling of 375 bad reviews to validate root cause distribution

## Tools
- SQL (PostgreSQL / DataGrip)
- Tableau — Dashboard
- Manual labeling — Root cause classification

## Dashboard
[View on Tableau Public](https://public.tableau.com/views/BadReviewRatebyPurchaseMonth-Olistdataset/WhyDoOlistCustomersLeaveBadReviewsAnalysisof375badreviewsJan2017Aug2018)

## Connect
[LinkedIn](https://www.linkedin.com/in/tamnguye-personal/) | [Kaggle](https://www.kaggle.com/code/tomrighhere/olist-bad-reviews-analysis-a-root-cause-approach)
