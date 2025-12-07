create database churn_analysis;

use churn_analysis

drop table if exists churn;

create table churn ( customer_id int primary key,
                          signup_date date,
                          last_order_date date,
                          orders_count int,
                          total_spend int,
                          city varchar(60),
                          segment varchar(60),
                          churn_flag int );                       
                      

*/// churn = 90 days not ordered 

select* from churn



 1.Segment-wise churn leakage
    SELECT segment,
       COUNT(*) AS total_customers,
       SUM(churn_flag) AS churned,
       ROUND(SUM(churn_flag) * 1.0 / COUNT(*), 2) AS churn_rate
FROM churn
GROUP BY segment
ORDER BY churn_rate DESC;

       

2.percentage of churn per city 
  
      select city, count(*) as total_custmores,
       sum(churn_flag) as total_churn,
      round(sum(churn_flag)/ count(*)*100,2)as percentage_churn
       from churn
       group by city;
       
       
       
       
       
 3 segementing customers as rfm (recency,frequency,monetory)
 
 

WITH base_rfm AS (
    SELECT
        customer_id,
        DATEDIFF(
            (SELECT MAX(last_order_date) FROM churn_analysis.churn),
            last_order_date
        ) AS recency,
        orders_count AS frequency,
        total_spend  AS monetary
    FROM churn_analysis.churn),

rfm_scores AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency ASC)    AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)  AS m_score
    FROM base_rfm)

SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_score,
    
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
            THEN 'Champions'

        WHEN r_score >= 4 AND f_score >= 3
            THEN 'Loyal Customers'

        WHEN r_score >= 3 AND f_score <= 2
            THEN 'Potential Loyalists'

        WHEN r_score <= 2 AND f_score >= 3
            THEN 'At Risk'

        WHEN r_score <= 2 AND f_score <= 2
            THEN 'Lost Customers'ELSE 'Others'
            END AS rfm_category
FROM rfm_scores;





      4. Monthly churn rate
        
	SELECT
    DATE_FORMAT(last_order_date, '%Y-%m') AS last_active_month,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn_flag = 1 THEN 1 ELSE 0 END) AS churned_customers,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churn_flag = 1 THEN 1 ELSE 0 END) / COUNT(*),2),'%') AS churn_rate
FROM churn
WHERE last_order_date IS NOT NULL
GROUP BY DATE_FORMAT(last_order_date, '%Y-%m')
ORDER BY last_active_month;

 5. Top spenders who churned
 
 SELECT customer_id, total_spend
FROM CHURN
WHERE churn_flag = 1
ORDER BY total_spend DESC
LIMIT 10 ;

6. City-wise churn

SELECT city,
       COUNT(*) AS total,
       SUM(churn_flag) AS churned,
       SUM(churn_flag) * 1.0 / COUNT(*) AS churn_rate
FROM CHURN
GROUP BY city
ORDER BY churn_rate DESC;


 7. Customers at risk (last order between 60–90 days)
 
 
SELECT
    COUNT(*) AS at_risk_customers,segment
FROM churn
WHERE DATEDIFF('2024-12-31', last_order_date) BETWEEN 60 AND 90
group by segment;


8. Predict churn using behavior patterns

   SELECT 
    customer_id,
    last_order_date,
    orders_count,
    total_spend,
    CASE 
        WHEN orders_count <= 2 THEN 'High Risk'
        WHEN DATEDIFF(last_order_date, '2024-12-31') BETWEEN 60 AND 90 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_flag
FROM churn;
