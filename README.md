PulseCart Customer Intelligence — Analysis Report

How to Rerun:-

1. Clone the repo and place the raw data under `data/csv/` and `data/images/` (folder structure expected by the notebook: `customers.csv`, `products.csv`, `orders.csv`, `support_tickets.csv`, `daily_ops.csv`, `image_labels.csv`, plus an `images/` directory with `damaged/`, `normal/`, `wrong_item/` subfolders).
2. Install dependencies (see Environment below).
3. Open `analysis.ipynb` in Jupyter and run all cells top to bottom — later stations (D onward) depend on cleaned data produced in Stations B and C, so cells must run in order.
4. Outputs (plots, metrics, confusion matrix) print inline; no external files are written.

Environment:-

1. Python 3.12
2. pandas, numpy
3. matplotlib, seaborn
4. scikit-learn (LogisticRegression, GradientBoostingClassifier, KMeans, DBSCAN, PCA, StandardScaler, metrics)
5. statsmodels (`proportions_ztest`)
6. tensorflow / keras (`ImageDataGenerator`, `Sequential`, CNN layers)
7. re (standard library, for regex extraction)

Install with:-
pip install pandas numpy matplotlib seaborn scikit-learn statsmodels tensorflow

Answers to the Five Business Questions:-

1. Who is leaving, and is any city or plan actually different from the rest?

Overall, 141 of 850 customers churned, an overall churn rate of 16.59%. Houston stood out with a churn rate of 30.32% (57 of 188 customers), compared with 12.69% (84 of 662 customers) across all other cities. A two-proportion z-test comparing Houston against the rest returned a p-value of 9.74e-09, giving strong statistical evidence that Houston's churn rate genuinely differs from the rest rather than being random variation. Houston is therefore the one city worth flagging for further investigation. No equivalent hypothesis test was run comparing subscription plans, so this analysis cannot support a statistically-backed claim about plan-level differences in churn.

2. Which products or categories are driving returns? Is that difference large enough to act on?

Kitchen products returned at **23.84% (170 of 713 orders)**, versus 6.49% (172 of 2,650 orders) for all other categories combined — roughly 3.7x higher. A two-proportion z-test comparing Kitchen to the rest produced a p-value of 3.58e-42, far below any conventional significance threshold, so this is not noise. The gap is both statistically significant and large in practical terms, making Kitchen a clear priority for return-reduction action (e.g., reviewing product listings, packaging, or fulfillment quality for that category). The notebook does not break down returns by individual product within Kitchen, so the root cause within the category is not yet identified.

3. Can you predict churn well enough to build a short outreach list — without leaking the future into the model?

The churn model was trained only on customer behavior recorded before a 1 June 2026 cutoff (order count, total spend, return rate, ticket count, plan, city, age, recency), and the train/test split was done chronologically by signup date rather than randomly, which avoids leaking post-cutoff information into training. A single-feature logistic regression baseline using only recency achieved a ROC-AUC of 0.782 but produced 0 precision and 0 recall at the default threshold — it ranks customers reasonably but can't classify them usefully out of the box. The full-feature Gradient Boosting model achieved 0.80 precision, 0.121 recall, and 0.735 ROC-AUC, with only 1 false positive and 29 false negatives on the test set. This means the model's positive predictions are highly trustworthy (80% of flagged customers really do churn) but it only catches about 12% of all churners. It is therefore usable as a small, high-confidence outreach list — not as a complete churn-detection system.

4. Did daily orders change after 1 June 2026, or is that just noise?

Daily order counts were analyzed on a time-ordered basis (no shuffling), with 1 June 2026 marked as the reference point. Average daily orders dropped from 175.9 before June 1 to 129.2 after June 1, a decrease of roughly 46.7 orders per day (~27%). For context, a naive previous-day baseline forecast had a mean absolute error of about 34.8 orders per day, so a shift of ~47 orders/day is larger than the model's typical day-to-day forecasting error, suggesting the drop is more than routine noise. However, no formal statistical significance test (e.g., a t-test on the before/after periods) was run in this analysis, so this remains an observed level shift rather than a statistically confirmed, causally-explained change — other factors (seasonality, the March promo ending, external events) haven't been ruled out.

5. What should PulseCart do in the next 30 days? Three actions, each tied to evidence.

1. Investigate Houston churn drivers. Houston's churn rate (30.32%, 57/188) is more than double the rest of the base (12.69%, 84/662), confirmed statistically significant (p = 9.74e-09). Review Houston-specific support tickets, delivery times, and local competition to identify a root cause before designing a retention offer.

2. Audit Kitchen category returns. Kitchen products return at 23.84% versus 6.49% elsewhere (p = 3.58e-42) — nearly 4x higher and not explainable by chance. Pull a sample of Kitchen return reasons and product listings to check for sizing/description mismatches, damage in transit, or quality issues, since 170 returned orders in this category alone is a meaningful cost.

3. Launch a targeted outreach list from the churn model, not a blanket campaign. The Gradient Boosting model flags churn-risk customers with 80% precision, so use its positive predictions as a short, high-confidence retention outreach list rather than relying on it to catch every at-risk customer (it only achieves 12% recall). Pair this with the ~27% drop in daily orders since 1 June — worth checking whether the same operational or promotional change behind that drop is also feeding the churn numbers.

Limitations
1. The plan-vs-churn relationship was not formally tested; only city was tested with a hypothesis test.
2. The Kitchen return-rate finding is category-level; no product-level breakdown was done to pinpoint specific SKUs.
3. The churn model has low recall (12.1%) — it should not be treated as a comprehensive churn detector, only as a precise shortlist generator.
4. The post-June-1 order drop is an observed level shift, not confirmed via a formal significance test; other confounding factors (seasonality, promo end date, external events) were not ruled out.
5. DBSCAN clustering (eps=0.8, min_samples=5) placed 106 of the customer records into a noise cluster (-1), indicating the chosen density parameters don't cleanly separate the full customer base — K-Means (k=3, silhouette score 0.317) was used as the primary segmentation instead.
6. The CNN image classifier reached 100% accuracy on a small holdout set (48 images across 3 classes), which is a strong result but on a very small sample — it should be validated on more data before being treated as production-ready.****
