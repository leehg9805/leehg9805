DROP TABLE IF EXISTS purchase_log;
CREATE TABLE purchase_log(
    dt              varchar(255)
  , order_id        integer
  , user_id         varchar(255)
  , purchase_amount integer
);

INSERT INTO purchase_log
VALUES
    ('2014-01-01',    1, 'rhwpvvitou', 13900)
  , ('2014-02-08',   95, 'chtanrqtzj', 28469)
  , ('2014-03-09',  168, 'bcqgtwxdgq', 18899)
  , ('2014-04-11',  250, 'kdjyplrxtk', 12394)
  , ('2014-05-11',  325, 'pgnjnnapsc',  2282)
  , ('2014-06-12',  400, 'iztgctnnlh', 10180)
  , ('2014-07-11',  475, 'eucjmxvjkj',  4027)
  , ('2014-08-10',  550, 'fqwvlvndef',  6243)
  , ('2014-09-10',  625, 'mhwhxfxrxq',  3832)
  , ('2014-10-11',  700, 'wyrgiyvaia',  6716)
  , ('2014-11-10',  775, 'cwpdvmhhwh', 16444)
  , ('2014-12-10',  850, 'eqeaqvixkf', 29199)
  , ('2015-01-09',  925, 'efmclayfnr', 22111)
  , ('2015-02-10', 1000, 'qnebafrkco', 11965)
  , ('2015-03-12', 1075, 'gsvqniykgx', 20215)
  , ('2015-04-12', 1150, 'ayzvjvnocm', 11792)
  , ('2015-05-13', 1225, 'knhevkibbp', 18087)
  , ('2015-06-10', 1291, 'wxhxmzqxuw', 18859)
  , ('2015-07-10', 1366, 'krrcpumtzb', 14919)
  , ('2015-08-08', 1441, 'lpglkecvsl', 12906)
  , ('2015-09-07', 1516, 'mgtlsfgfbj',  5696)
  , ('2015-10-07', 1591, 'trgjscaajt', 13398)
  , ('2015-11-06', 1666, 'ccfbjyeqrb',  6213)
  , ('2015-12-05', 1741, 'onooskbtzp', 26024)
;

-- 9-8 매출과 관련된 지표를 집계하는 쿼리
WITH
daily_purchase AS(
  SELECT
	dt
	, substring(dt, 1, 4) AS year
	, substring(dt, 6, 2) AS month
	, substring(dt, 9, 2) AS date
	, SUM(purchase_amount) AS purchase_amount
	, COUNT(order_id) AS orders
	FROM purchase_log
	GROUP BY dt
)
, monthly_purchase AS(
 SELECT
	year
	, month
	, SUM(orders) AS orders
	, AVG(purchase_amount) AS avg_amount
	, SUM(purchase_amount) AS monthly
   FROM daily_purchase
   GROUP BY year, month
)
SELECT
  concat(year, '-', month) AS year_month
  , orders
  , avg_amount
  , monthly
  , SUM(monthly)
      OVER(PARTITION BY year ORDER BY month ROWS UNBOUNDED PRECEDING)
	  AS agg_amount
	  -- 12개월 전의 매출 구하기
	  , LAG(monthly, 12)
	    OVER(ORDER BY year, month)
		AS last_year
		-- 12개월 전의 매출과 비교해서 비율 구하기
		, 100.0
		* monthly
		/LAG(monthly, 12)
		OVER(ORDER BY year, month)
		AS rate
	FROM
	 monthly_purchase
	 ORDER BY
	  year_month
	  ;
