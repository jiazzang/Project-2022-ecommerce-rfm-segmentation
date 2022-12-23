/**** 데이터베이스 사용 ****/
USE project;


/********* 2. RFM Segmentation 기준 부여 근거 찾기 *********/

/** 2-1. Recency **/
/* 2-1-1. 재구매 고객별 평균 구매 주기 */
WITH customer_order_records AS (
    SELECT customer_id
          ,order_id
          ,order_date AS order_date_1
          ,LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS order_date_2
          ,DATEDIFF(LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date), order_date) AS date_diff
    FROM records
    GROUP BY customer_id, order_id, order_date
    )
SELECT customer_id
      ,ROUND(AVG(date_diff), 2) AS order_cycle_avg
FROM customer_order_records
GROUP BY customer_id
HAVING order_cycle_avg IS NOT NULL;

/* 2-1-2. 재구매 고객들의 평균 구매 주기, 고객별 평균 구매 주기의 최대값 계산 */
WITH total AS (
    WITH customer_order_records AS (
        SELECT customer_id
              ,order_id
              ,order_date AS order_date_1
              ,LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS order_date_2
              ,DATEDIFF(LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date), order_date) AS date_diff
        FROM records
        GROUP BY customer_id, order_id, order_date
        )
    SELECT customer_id
          ,ROUND(AVG(date_diff), 2) AS order_cycle_avg
    FROM customer_order_records
    GROUP BY customer_id
    HAVING order_cycle_avg IS NOT NULL
)
SELECT ROUND(AVG(order_cycle_avg), 2) total_avg
      ,MAX(order_cycle_avg) AS total_max
FROM total;

/* 2-1-3. 고객들의 마지막 주문 월 */
WITH customer_last_order AS (
  SELECT customer_id
        ,MAX(order_date) AS last_order_date
  FROM records
  GROUP BY customer_id
)
SELECT DATE_FORMAT(last_order_date, '%Y-%m') AS last_order_month
      ,COUNT(*) AS customer_count
FROM customer_last_order
GROUP BY last_order_month
ORDER BY last_order_month;


/** 2-2. Frequency **/
/* 2-2-1. 구매 횟수별 고객 수 계산 */
-- order_count: 구매횟수, customer_count: 고객 수 --
WITH customer_order AS (
  SELECT customer_id
        ,COUNT(DISTINCT order_id) AS order_count 
  FROM records
  GROUP BY customer_id
  ORDER BY order_count DESC
)
SELECT order_count
      ,COUNT(customer_id) AS customer_count
FROM customer_order
GROUP BY order_count
ORDER BY order_count;

/* 2-2-2. 평균 구매 횟수 계산 */
WITH order_count AS ( 
SELECT customer_id AS customer
      ,COUNT(DISTINCT order_id) AS order_count 
FROM records
GROUP BY customer_id
ORDER BY order_count DESC
)
SELECT ROUND(AVG(order_count), 2) AS order_count_avg
FROM order_count;


/** 2-3. Monetary **/
/* 2-3-1. 판매 금액 범위별 고객 수 계산 */
-- sales_band: 판매 금액 범위, customer_count: 고객 수 --
WITH customer_sales_band AS (
    WITH customer_sales AS (
      SELECT customer_id
            ,SUM(sales) AS sales
      FROM records
      GROUP BY customer_id
    )
    SELECT customer_id
          ,CASE WHEN sales BETWEEN 0 AND 100 THEN 1
                WHEN sales BETWEEN 100 AND 200 THEN 2
                WHEN sales BETWEEN 200 AND 300 THEN 3
                WHEN sales BETWEEN 300 AND 400 THEN 4
                WHEN sales BETWEEN 400 AND 500 THEN 5
                WHEN sales BETWEEN 500 AND 600 THEN 6
                WHEN sales BETWEEN 600 AND 700 THEN 7
                WHEN sales BETWEEN 700 AND 800 THEN 8
                WHEN sales BETWEEN 800 AND 900 THEN 9
                WHEN sales BETWEEN 900 AND 1000 THEN 10
                WHEN sales BETWEEN 1000 AND 3000 THEN 11
                WHEN sales BETWEEN 3000 AND 5000 THEN 12
                WHEN sales BETWEEN 5000 AND 10000 THEN 13
                WHEN sales > 10000 THEN 14
           END AS sales_band
    FROM  customer_sales
)
SELECT sales_band
      ,COUNT(customer_id) AS customer_count
FROM customer_sales_band
GROUP BY sales_band
ORDER BY sales_band;

/* 2-3-2. 평균 판매 금액 계산 */
WITH customer_sales AS (
  SELECT customer_id
        ,ROUND(SUM(sales), 2) AS sales
  FROM records
  GROUP BY customer_id
  ORDER BY sales DESC
)
SELECT ROUND(AVG(sales), 2) AS sales_average
FROM customer_sales;



/* 2-4. Recency, Frequency, Monetary 기준에 의한 RFM Segmentation */
SELECT IF(last_order_date >= '2020-09-01', 1, 0) AS recency
      ,IF(cnt_orders >= 3, 1, 0) AS frequency
      ,IF(sum_sales >= 1334.64, 1, 0) AS monetary
      ,COUNT(DISTINCT customer_id) AS customer_count 
FROM customer_stats
GROUP BY recency, frequency, monetary
ORDER BY recency DESC
        ,frequency DESC
        ,monetary DESC;
