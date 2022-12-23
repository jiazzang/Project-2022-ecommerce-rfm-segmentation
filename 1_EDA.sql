/**** 데이터베이스 사용 ****/
USE project;

/********* 1. EDA *********/
/** 1-1. 카테고리별 주문비율 및 주문량  **/
/* 1-1-1. 대분류 카테고리별 주문 비율 계산 */
SELECT ROUND(COUNT(CASE WHEN category = 'Furniture' THEN order_id END) * 100 / COUNT(order_id), 1) AS Furniture
      ,ROUND(COUNT(CASE WHEN category = 'Office Supplies' THEN order_id END) * 100 / COUNT(order_id), 1) AS 'Office Supplies'
      ,ROUND(COUNT(CASE WHEN category = 'Technology' THEN order_id END) * 100 / COUNT(order_id), 1) AS Technology
FROM records;

/* 1-1-2. 대분류, 중분류 카테고리별 주문량 Top 5 계산 */
SELECT category
      ,sub_category
      ,COUNT(order_id) AS order_count
FROM records
GROUP BY category, sub_category
ORDER BY order_count DESC
LIMIT 5;

/** 1-2. 고객군별 주문량 비율, 매출액 비율 계산 **/
/* 1-2-1. 고객군별 주문량 비율 */
SELECT ROUND(COUNT(DISTINCT CASE WHEN segment = 'Consumer' THEN order_id END) * 100 / COUNT(DISTINCT order_id), 1) AS Consumer
      ,ROUND(COUNT(DISTINCT CASE WHEN segment = 'Home Office' THEN order_id END) * 100 / COUNT(DISTINCT order_id), 1) AS 'Home Office'
      ,ROUND(COUNT(DISTINCT CASE WHEN segment = 'Corporate' THEN order_id END) * 100 / COUNT(DISTINCT order_id), 1) AS Corporate
FROM records;

/* 1-2-2. 고객군별 매출액 비율 */
SELECT ROUND(SUM(CASE WHEN segment = 'Consumer' THEN sales END) * 100 / SUM(sales), 1) AS Consumer
      ,ROUND(SUM(CASE WHEN segment = 'Home Office' THEN sales END) * 100 / SUM(sales), 1) AS 'Home Office'
      ,ROUND(SUM(CASE WHEN segment = 'Corporate' THEN sales END) * 100 / SUM(sales), 1) AS Corporate
FROM records;

/** 1-3. 구매 금액 **/
/* 1-3-1. 구매 금액 Top 10 조회 */
SELECT customer_id
      ,segment
      ,ROUND(SUM(sales), 2) AS sales
FROM records
GROUP BY customer_id, segment
ORDER BY sales DESC
LIMIT 10;

/* 1-3-2. 고객군별 1인당 평균 구매 금액 계산 */
SELECT segment
    , ROUND(SUM(sales), 2) AS segment_sales 
    , COUNT(DISTINCT customer_id) AS segment_count
    , ROUND(SUM(sales) / COUNT(DISTINCT customer_id), 2) AS per_sales
FROM records
GROUP BY segment
ORDER BY per_sales DESC;