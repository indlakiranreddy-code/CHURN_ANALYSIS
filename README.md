# CHURN_ANALYSIS

 Customer Churn Analysis (SQL Project)
🔍 Overview

This project analyzes customer churn using SQL. The goal is to identify customers who stopped purchasing, understand churn patterns across segments and cities, quantify revenue loss, and reveal retention opportunities.

The analysis is performed on a structured dataset of 300 customers with purchase behavior, demographic attributes, and churn status.

📁 Dataset Description
Column	Description
customer_id	Unique customer identifier
signup_date	Date the customer joined
last_order_date	Most recent purchase date
orders_count	Total lifetime orders
total_spend	Customer lifetime value (LTV)
city	Customer location
segment	Customer grouping (Premium/Standard/Basic)
churn_flag	1 = churned (>90 days inactive), 0 = active
🎯 Project Objectives

Detect churned customers using inactivity rules.

Calculate churn rate and revenue impact.

Identify high-value customers who churned.

Understand churn patterns across segments and cities.

Build RFM (Recency, Frequency, Monetary) scoring.

Perform cohort-based retention analysis.

Highlight customers at high churn risk (60–90 days inactivity).

🛠 Tools & Technologies

SQL (Window Functions, Aggregations, Cohorts, Case Logic)

Excel (Dataset creation)



📌 SQL Analysis & Key Queries
1️⃣ Identify churned customers (>90 days inactive)
SELECT customer_id, last_order_date
FROM customers
WHERE DATEDIFF(day, last_order_date, '2024-12-31') > 90;

2️⃣ Monthly Churn Rate
SELECT 
    FORMAT(last_order_date, 'yyyy-MM') AS last_active_month,
    SUM(churn_flag) AS churned,
    COUNT(*) AS total_customers,
    SUM(churn_flag)*1.0 / COUNT(*) AS churn_rate
FROM customers
GROUP BY FORMAT(last_order_date, 'yyyy-MM');

3️⃣ Revenue Lost Due to Churn
SELECT SUM(total_spend) AS revenue_lost
FROM customers
WHERE churn_flag = 1;

4️⃣ Segment-wise Churn Rate
SELECT 
    segment,
    COUNT(*) AS total_customers,
    SUM(churn_flag) AS churned,
    SUM(churn_flag) * 1.0 / COUNT(*) AS churn_rate
FROM customers
GROUP BY segment
ORDER BY churn_rate DESC;

5️⃣ City-wise Churn Rate
SELECT 
    city,
    COUNT(*) AS total_customers,
    SUM(churn_flag) AS churned,
    SUM(churn_flag)*1.0 / COUNT(*) AS churn_rate
FROM customers
GROUP BY city
ORDER BY churn_rate DESC;

6️⃣ High-Value Customers Who Churned
SELECT customer_id, total_spend
FROM customers
WHERE churn_flag = 1
ORDER BY total_spend DESC
FETCH FIRST 10 ROWS ONLY;

7️⃣ At-Risk Customers (60–90 Days Inactive)
SELECT *
FROM customers
WHERE DATEDIFF(day, last_order_date, '2024-12-31')
      BETWEEN 60 AND 90;

8️⃣ Cohort Retention Analysis
SELECT 
    FORMAT(signup_date,'yyyy-MM') AS cohort_month,
    COUNT(*) AS customers_in_cohort,
    SUM(CASE WHEN churn_flag = 0 THEN 1 END) AS retained,
    SUM(CASE WHEN churn_flag = 0 THEN 1 END)*1.0/COUNT(*) AS retention_rate
FROM customers
GROUP BY FORMAT(signup_date,'yyyy-MM')
ORDER BY cohort_month;

9️⃣ RFM (Recency, Frequency, Monetary) Scoring
SELECT 
    customer_id,
    DATEDIFF(day,last_order_date,'2024-12-31') AS recency,
    orders_count AS frequency,
    total_spend AS monetary
FROM customers;

📈 Key Insights

A significant portion of customers show 90+ days of inactivity, meaning clear churn.

Basic segment customers churn the most — low engagement and low loyalty.

Several high-value customers have churned, representing major revenue loss.

Churn varies sharply by city, indicating local competition or service gaps.

60–90 day inactive customers form a critical recovery segment.

Cohort retention patterns decline after initial signup, signaling weak long-term engagement

🧾 Conclusion
This project demonstrates the full lifecycle of churn analytics — from dataset creation, SQL exploration, retention modeling, RFM scoring, and identification of business risks. The insights produced can directly guide customer retention strategies and revenue recovery initiatives.
