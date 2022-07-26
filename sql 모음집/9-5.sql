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

with
daily_purchase as(
select
	   dt
	--'연', '월', '일'을 각각 추구
	, substring(dt, 1, 4) as year
	, substring(dt, 6, 2) as month
	, substring(dt, 9, 2) as date
	, sum(purchase_amount) as purchase_amount
	, count(order_id) as orders
	from purchase_log
	group by dt
)
, monthly_amount as (
  -- 월별 매출 집계하기
  select
	 year
	, month
	, sum(purchase_amount) as amount
  from daily_purchase
  group by year, month
)
, calc_index as (
  select
     year
    , month
	, amount
	  -- 2015 누계 매출
	 , sum(case when year = '2015' then amount end)
	     over(order by year, month rows unbounded preceding)
	  as agg_amount
	   -- 당월부터 11개월 이전까지 매출 합계(이동년계) 집계하기
	 , sum(amount)
	    over(order by year, month rows between 11 preceding and current row)
	   as year_avg_amount
	from
	   monthly_amount
	order by
	  year, month
)
-- 마지막으로 2015년의 데이터만 압축
select
   concat(year,'-',month) as year_month
   , amount
   , agg_amount
   , year_avg_amount
   from
    calc_index
   where
    year ='2015'
   order by
     year_month
	 ;