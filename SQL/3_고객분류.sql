/* 데이터베이스 사용 */
USE project;


/********* 3. 고객 분류 *********/

/** 3-1. VIP 고객 **/
/* 3-1-1. VIP 고객의 카테고리별 주문 수 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) >= '2020-09-01'
     AND COUNT(DISTINCT order_id) >= 3
     AND SUM(sales) >= 1334.64
)
SELECT r.category
      ,COUNT(order_id) AS order_count
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY order_count DESC;

/* 3-1-2. VIP 고객의 카테고리별 매출액 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) >= '2020-09-01'
     AND COUNT(DISTINCT order_id) >= 3
     AND SUM(sales) >= 1334.64
)
SELECT r.category
      ,ROUND(SUM(r.sales), 2) AS sum_sales
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY sum_sales DESC;

/** 3-2. 최근, 자주 구매한 고객 **/

/* 3-2-1. 최근, 자주 구매한 고객의 카테고리별 주문 수 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) >= '2020-09-01'
     AND COUNT(DISTINCT order_id) >= 3
     AND SUM(sales) < 1334.64
)
SELECT r.category
      ,COUNT(order_id) AS order_count
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY order_count DESC;

/* 3-2-2. 최근, 자주 구매한 고객의 카테고리별 매출액 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) >= '2020-09-01'
     AND COUNT(DISTINCT order_id) >= 3
     AND SUM(sales) < 1334.64
)
SELECT r.category
      ,ROUND(SUM(r.sales), 2) AS sum_sales
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY sum_sales DESC;

/** 3-3. 최근, 많은 금액을 지불한 고객 **/

/* 3-3-1. 최근, 많은 금액을 구매한 고객의 카테고리별 주문 수 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) >= '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) >= 1334.64
)
SELECT r.category
      ,COUNT(order_id) AS order_count
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY order_count DESC;

/*3-3-2. 최근, 많은 금액을 구매한 고객의 카테고리별 매출액 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) >= '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) >= 1334.64
)
SELECT r.category
      ,ROUND(SUM(r.sales), 2) AS sum_sales
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY sum_sales DESC;

/* 3-3-3. 최근, 많은 금액을 지불한 구매한 고객의 평균 구매주기 */
WITH total_avg AS (
    WITH order_cycle AS (
        WITH customer AS (
          SELECT customer_id
          FROM records
          GROUP BY customer_id
          HAVING MAX(order_date) >= '2020-09-01'
            AND COUNT(DISTINCT order_id) < 3
            AND SUM(sales) >= 1334.64
        )
        SELECT c.customer_id
              ,order_id
              ,order_date AS order_date_1
              ,LEAD(order_date, 1) OVER (PARTITION BY c.customer_id ORDER BY order_date) AS order_date_2
              ,DATEDIFF(LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date), order_date) AS date_diff
        FROM customer AS c
            INNER JOIN records AS r ON c.customer_id = r.customer_id
        GROUP BY c.customer_id, order_id, order_date
    )
    SELECT customer_id
          ,AVG(date_diff) AS order_cycle_avg
    FROM order_cycle
    GROUP BY customer_id
)
SELECT ROUND(AVG(order_cycle_avg), 2) AS total_cycle_avg
FROM total_avg;

/* 3-3-4. 최근, 많은 금액을 지불한 고객의 평균 구매횟수 */
WITH customer AS (
  SELECT customer_id
        ,COUNT(DISTINCT order_id) AS order_count
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) >= '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) >= 1334.64
)
SELECT ROUND(AVG(order_count), 2) AS order_avg
FROM customer;

/* 3-3-5. 최근, 많은 금액을 지불한 고객의 평균 구매금액 */
WITH customer AS (
  SELECT customer_id
        ,ROUND(SUM(sales), 2) AS sum_sales
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) >= '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) >= 1334.64
)
SELECT ROUND(AVG(sum_sales), 2) AS sales_avg
FROM customer;

/* 3-3-6. 최근, 많은 금액을 지불한 고객의 구매횟수별 고객수 */
WITH customer AS (
  SELECT customer_id
        ,COUNT(DISTINCT order_id) AS order_count
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) >= '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) >= 1334.64
)
SELECT ROUND(SUM(IF(order_count=1, 1, 0)) * 100 / COUNT(customer_id)) AS once
      ,ROUND(SUM(IF(order_count=2, 1, 0)) * 100 / COUNT(customer_id)) AS twice
FROM customer;

/** 3-4. 최근에 구매한 고객 **/
/* 3-4-1. 최근에 구매한 고객의 카테고리별 주문 수 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) >= '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) < 1334.64
)
SELECT r.category
      ,COUNT(order_id) AS order_count
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY order_count DESC;

/* 3-4-2. 최근에 구매한 고객의 카테고리별 매출액 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) >= '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) < 1334.64
)
SELECT r.category
      ,ROUND(SUM(r.sales), 2) AS sum_sales
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY sum_sales DESC;

/* 3-4-3. 최근에 구매한 고객의 평균 구매주기 */
WITH total_avg AS (
    WITH order_cycle AS (
        WITH customer AS (
          SELECT customer_id
          FROM records
          GROUP BY customer_id
          HAVING MAX(order_date) >= '2020-09-01'
            AND COUNT(DISTINCT order_id) < 3
            AND SUM(sales) < 1334.64
        )
        SELECT c.customer_id
              ,order_id
              ,order_date AS order_date_1
              ,LEAD(order_date, 1) OVER (PARTITION BY c.customer_id ORDER BY order_date) AS order_date_2
              ,DATEDIFF(LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date), order_date) AS date_diff
        FROM customer AS c
             INNER JOIN records AS r ON c.customer_id = r.customer_id
        GROUP BY c.customer_id, order_id, order_date
    )
    SELECT customer_id
          ,AVG(date_diff) AS order_cycle_avg
    FROM order_cycle
    GROUP BY customer_id
)
SELECT ROUND(AVG(order_cycle_avg), 2) AS total_cycle_avg
FROM total_avg;

/* 3-4-4. 최근에 구매한 고객의 평균 구매횟수*/
WITH customer AS (
  SELECT customer_id
        ,COUNT(DISTINCT order_id) AS order_count
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) >= '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) < 1334.64
)
SELECT ROUND(AVG(order_count), 2) AS order_avg
FROM customer;

/* 3-4-5. 최근에 구매한 고객의 평균 구매금액 */
WITH customer AS (
  SELECT customer_id
        ,ROUND(SUM(sales), 2) AS sum_sales
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) >= '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) < 1334.64
)
SELECT ROUND(AVG(sum_sales), 2) AS sales_avg
FROM customer;

/* 3-4-6. 최근에 구매한 고객의 구매횟수별 고객수 */
WITH customer AS (
  SELECT customer_id
        ,COUNT(DISTINCT order_id) AS order_count
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) >= '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) < 1334.64
)
SELECT ROUND(SUM(IF(order_count=1, 1, 0)) * 100 / COUNT(customer_id)) AS once
      ,ROUND(SUM(IF(order_count=2, 1, 0)) * 100 / COUNT(customer_id)) AS twice
FROM customer;

/** 3-5. 잠든 VIP 고객 **/
/* 3-5-1. 잠든 VIP 고객의 카테고리별 주문 수 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) >= 3
     AND SUM(sales) >= 1334.64
)
SELECT r.category
      ,COUNT(order_id) AS order_count
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY order_count DESC;

/* 3-5-2. 잠든 VIP 고객의 카테고리별 매출액 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) >= 3
     AND SUM(sales) >= 1334.64
)
SELECT r.category
      ,ROUND(SUM(r.sales), 2) AS sum_sales
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY sum_sales DESC;

/* 3-5-3. 잠든 VIP 고객의 평균 구매주기 */
WITH total_avg AS (
    WITH order_cycle AS (
        WITH customer AS (
          SELECT customer_id
          FROM records
          GROUP BY customer_id
          HAVING MAX(order_date) < '2020-09-01'
            AND COUNT(DISTINCT order_id) >= 3
            AND SUM(sales) >= 1334.64
        )
        SELECT c.customer_id
              ,order_id
              ,order_date AS order_date_1
              ,LEAD(order_date, 1) OVER (PARTITION BY c.customer_id ORDER BY order_date) AS order_date_2
              ,DATEDIFF(LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date), order_date) AS date_diff
        FROM customer AS c
             INNER JOIN records AS r ON c.customer_id = r.customer_id
        GROUP BY c.customer_id, order_id, order_date
    )
    SELECT customer_id
          ,AVG(date_diff) AS order_cycle_avg
    FROM order_cycle
    GROUP BY customer_id
)
SELECT ROUND(AVG(order_cycle_avg), 2) AS total_cycle_avg
FROM total_avg;

/* 3-5-4. 잠든 VIP 고객의 평균 구매횟수 */
WITH customer AS (
  SELECT customer_id
        ,COUNT(DISTINCT order_id) AS order_count
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) >= 3
     AND SUM(sales) >= 1334.64
)
SELECT ROUND(AVG(order_count), 2) AS order_avg
FROM customer;

/* 3-5-5. 잠든 VIP 고객의 평균 구매금액 */
WITH customer AS (
  SELECT customer_id
        ,ROUND(SUM(sales), 2) AS sum_sales
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) >= 3
     AND SUM(sales) >= 1334.64
)
SELECT ROUND(AVG(sum_sales), 2) AS sales_avg
FROM customer;

/* 3-5-6. 잠든 VIP 고객의 월별 구매횟수 */
WITH month AS (    
    WITH customer AS (
      SELECT customer_id
      FROM records
      GROUP BY customer_id
      HAVING MAX(order_date) < '2020-09-01'
         AND COUNT(DISTINCT order_id) >= 3
         AND SUM(sales) >= 1334.64
      )
    SELECT c.customer_id
          ,order_id
          ,DATE_FORMAT(order_date, '%Y-%m') AS order_month
    FROM customer AS c
         INNER JOIN records AS r ON c.customer_id = r.customer_id
    GROUP BY c.customer_id, order_id, order_date
    ORDER BY customer_id
    )
SELECT order_month
      ,COUNT(order_id) AS order_count
FROM month
GROUP BY order_month
ORDER BY order_month;

/** 3-6. 자주 구매한 고객 **/
/* 3-6-1. 자주 구매한 고객의 카테고리별 주문 수 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) >= 3
     AND SUM(sales) < 1334.64
)
SELECT r.category
      ,COUNT(order_id) AS order_count
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY order_count DESC;

/* 3-6-2. 자주 구매한 고객의 카테고리별 매출액 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) >= 3
     AND SUM(sales) < 1334.64
)
SELECT r.category
      ,ROUND(SUM(r.sales), 2) AS sum_sales
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY sum_sales DESC;

/* 3-6-3. 자주 구매한 고객의 평균 구매주기 */
WITH total_avg AS (
    WITH order_cycle AS (
        WITH customer AS (
          SELECT customer_id
          FROM records
          GROUP BY customer_id
          HAVING MAX(order_date) < '2020-09-01'
            AND COUNT(DISTINCT order_id) >= 3
            AND SUM(sales) < 1334.64
        )
        SELECT c.customer_id
              ,order_id
              ,order_date AS order_date_1
              ,LEAD(order_date, 1) OVER (PARTITION BY c.customer_id ORDER BY order_date) AS order_date_2
              ,DATEDIFF(LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date), order_date) AS date_diff
        FROM customer AS c
             INNER JOIN records AS r ON c.customer_id = r.customer_id
        GROUP BY c.customer_id, order_id, order_date
    )
    SELECT customer_id
          ,AVG(date_diff) AS order_cycle_avg
    FROM order_cycle
    GROUP BY customer_id
)
SELECT ROUND(AVG(order_cycle_avg), 2) AS total_cycle_avg
FROM total_avg;

/* 3-6-4. 자주 구매한 고객의 평균 구매횟수 */
WITH customer AS (
  SELECT customer_id
        ,COUNT(DISTINCT order_id) AS order_count
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) >= 3
     AND SUM(sales) < 1334.64
)
SELECT ROUND(AVG(order_count), 2) AS order_avg
FROM customer;

/* 3-6-5. 자주 구매한 고객의 평균 구매금액 */
WITH customer AS (
  SELECT customer_id
        ,ROUND(SUM(sales), 2) AS sum_sales
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) >= 3
     AND SUM(sales) < 1334.64
)
SELECT ROUND(AVG(sum_sales), 2) AS sales_avg
FROM customer;

/** 3-7. 과거에 많은 금액을 지불한 고객 **/
/* 3-7-1. 과거에 많은 금액을 지불한 고객의 카테고리별 주문 수 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) >= 1334.64
)
SELECT r.category
      ,COUNT(order_id) AS order_count
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY order_count DESC;

/* 3-7-2. 과거에 많은 금액을 지불한 고객의 카테고리별 매출액 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) >= 1334.64
)
SELECT r.category
      ,ROUND(SUM(r.sales), 2) AS sum_sales
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY sum_sales DESC;

/* 3-7-3. 과거에 많은 금액을 지불한 고객의 평균 구매주기 */
WITH total_avg AS (
    WITH order_cycle AS (
        WITH customer AS (
          SELECT customer_id
          FROM records
          GROUP BY customer_id
          HAVING MAX(order_date) < '2020-09-01'
            AND COUNT(DISTINCT order_id) < 3
            AND SUM(sales) >= 1334.64
        )
        SELECT c.customer_id
              ,order_id
              ,order_date AS order_date_1
              ,LEAD(order_date, 1) OVER (PARTITION BY c.customer_id ORDER BY order_date) AS order_date_2
              ,DATEDIFF(LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date), order_date) AS date_diff
        FROM customer AS c
             INNER JOIN records AS r ON c.customer_id = r.customer_id
        GROUP BY c.customer_id, order_id, order_date
    )
    SELECT customer_id
          ,AVG(date_diff) AS order_cycle_avg
    FROM order_cycle
    GROUP BY customer_id
)
SELECT ROUND(AVG(order_cycle_avg), 2) AS total_cycle_avg
FROM total_avg;

/* 3-7-4. 과거에 많은 금액을 지불한 고객의 평균 구매횟수 */
WITH customer AS (
  SELECT customer_id
        ,COUNT(DISTINCT order_id) AS order_count
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) >= 1334.64
)
SELECT ROUND(AVG(order_count), 2) AS order_avg
FROM customer;

/* 3-7-5. 과거에 많은 금액을 지불한 고객의 평균 구매금액 */
WITH customer AS (
  SELECT customer_id
        ,ROUND(SUM(sales), 2) AS sum_sales
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) >= 1334.64
)
SELECT ROUND(AVG(sum_sales), 2) AS sales_avg
FROM customer;

/* 3-7-6. 과거에 많은 금액을 지불한 고객의 구매횟수별 고객수 */
WITH customer AS (
  SELECT customer_id
        ,COUNT(DISTINCT order_id) AS order_count
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) >= 1334.64
)
SELECT ROUND(SUM(IF(order_count=1, 1, 0)) * 100 / COUNT(customer_id)) AS once
      ,ROUND(SUM(IF(order_count=2, 1, 0)) * 100 / COUNT(customer_id)) AS twice
FROM customer;

/* 3-7-7. 과거에 많은 금액을 지불한 고객의 월별 구매횟수 */
WITH month AS (    
    WITH customer AS (
      SELECT customer_id
      FROM records
      GROUP BY customer_id
      HAVING MAX(order_date) < '2020-09-01'
         AND COUNT(DISTINCT order_id) < 3
         AND SUM(sales) >= 1334.64
      )
    SELECT c.customer_id
          ,order_id
          ,DATE_FORMAT(order_date, '%Y-%m') AS order_month
    FROM customer AS c
         INNER JOIN records AS r ON c.customer_id = r.customer_id
    GROUP BY c.customer_id, order_id, order_date
    ORDER BY customer_id
    )
SELECT order_month
      ,COUNT(order_id) AS order_count
FROM month
GROUP BY order_month
ORDER BY order_month;

/** 3-8. 이탈 고객 **/
/* 3-8-1. 이탈 고객의 카테고리별 주문 수 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) < 1334.64
)
SELECT r.category
      ,COUNT(order_id) AS order_count
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY order_count DESC;

/* 3-8-2. 이탈 고객의 카테고리별 매출액 */
WITH customer AS (
  SELECT customer_id
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) < 1334.64
)
SELECT r.category
      ,ROUND(SUM(r.sales), 2) AS sum_sales
FROM customer AS c
    INNER JOIN records AS r ON c.customer_id = r.customer_id
GROUP BY r.category
ORDER BY sum_sales DESC;

/* 3-8-3. 이탈 고객의 평균 구매주기 */
WITH total_avg AS (
    WITH order_cycle AS (
        WITH customer AS (
          SELECT customer_id
          FROM records
          GROUP BY customer_id
          HAVING MAX(order_date) < '2020-09-01'
            AND COUNT(DISTINCT order_id) < 3
            AND SUM(sales) < 1334.64
        )
        SELECT c.customer_id
              ,order_id
              ,order_date AS order_date_1
              ,LEAD(order_date, 1) OVER (PARTITION BY c.customer_id ORDER BY order_date) AS order_date_2
              ,DATEDIFF(LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date), order_date) AS date_diff
        FROM customer AS c
             INNER JOIN records AS r ON c.customer_id = r.customer_id
        GROUP BY c.customer_id, order_id, order_date
    )
    SELECT customer_id
          ,AVG(date_diff) AS order_cycle_avg
    FROM order_cycle
    GROUP BY customer_id
)
SELECT ROUND(AVG(order_cycle_avg), 2) AS total_cycle_avg
FROM total_avg;

/* 3-8-4. 이탈 고객의 평균 구매횟수 */
WITH customer AS (
  SELECT customer_id
        ,COUNT(DISTINCT order_id) AS order_count
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) < 1334.64
)
SELECT ROUND(AVG(order_count), 2) AS order_avg
FROM customer;

/* 3-8.5 이탈 고객의 평균 구매금액 */
WITH customer AS (
  SELECT customer_id
        ,ROUND(SUM(sales), 2) AS sum_sales
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) < 1334.64
)
SELECT ROUND(AVG(sum_sales), 2) AS sales_avg
FROM customer;

/* 3-8-6. 이탈 고객의 구매횟수별 고객수 */
WITH customer AS (
  SELECT customer_id
        ,COUNT(DISTINCT order_id) AS order_count
  FROM records
  GROUP BY customer_id
  HAVING MAX(order_date) < '2020-09-01'
     AND COUNT(DISTINCT order_id) < 3
     AND SUM(sales) < 1334.64
)
SELECT ROUND(SUM(IF(order_count=1, 1, 0)) * 100 / COUNT(customer_id)) AS once
      ,ROUND(SUM(IF(order_count=2, 1, 0)) * 100 / COUNT(customer_id)) AS twice
FROM customer;
