DROP TABLE IF EXISTS purchase_log;
CREATE TABLE purchase_log(
    dt              varchar(255)
  , order_id        integer
  , user_id         varchar(255)
  , purchase_amount integer
);

INSERT INTO purchase_log
VALUES
    ('2014-01-01',  1, 'rhwpvvitou', 13900)
  , ('2014-01-01',  2, 'hqnwoamzic', 10616)
  , ('2014-01-02',  3, 'tzlmqryunr', 21156)
  , ('2014-01-02',  4, 'wkmqqwbyai', 14893)
  , ('2014-01-03',  5, 'ciecbedwbq', 13054)
  , ('2014-01-03',  6, 'svgnbqsagx', 24384)
  , ('2014-01-03',  7, 'dfgqftdocu', 15591)
  , ('2014-01-04',  8, 'sbgqlzkvyn',  3025)
  , ('2014-01-04',  9, 'lbedmngbol', 24215)
  , ('2014-01-04', 10, 'itlvssbsgx',  2059)
  , ('2014-01-05', 11, 'jqcmmguhik',  4235)
  , ('2014-01-05', 12, 'jgotcrfeyn', 28013)
  , ('2014-01-05', 13, 'pgeojzoshx', 16008)
  , ('2014-01-06', 14, 'msjberhxnx',  1980)
  , ('2014-01-06', 15, 'tlhbolohte', 23494)
  , ('2014-01-06', 16, 'gbchhkcotf',  3966)
  , ('2014-01-07', 17, 'zfmbpvpzvu', 28159)
  , ('2014-01-07', 18, 'yauwzpaxtx',  8715)
  , ('2014-01-07', 19, 'uyqboqfgex', 10805)
  , ('2014-01-08', 20, 'hiqdkrzcpq',  3462)
  , ('2014-01-08', 21, 'zosbvlylpv', 13999)
  , ('2014-01-08', 22, 'bwfbchzgnl',  2299)
  , ('2014-01-09', 23, 'zzgauelgrt', 16475)
  , ('2014-01-09', 24, 'qrzfcwecge',  6469)
  , ('2014-01-10', 25, 'njbpsrvvcq', 16584)
  , ('2014-01-10', 26, 'cyxfgumkst', 11339)
;

-- 9-3 날짜별 매출과 당월 누계 매출을 집계하는 쿼리
select
   dt
   -- '연-월' 추출하기
   , substring(dt,1,7) as year_month
   , sum(purchase_amount) as total_amount
   , sum(sum(purchase_amount))
     over(partition by substring(dt,1,7) order by dt rows unbounded preceding)
	 as agg_amount
 from
   purchase_log
 group by dt
 order by dt
 ;
 
-- 9-4 날짜별 매출을 일시 테이블로 만드는 쿼리
with
daily_purchase as (
  select 
    dt
     -- '연','월','일'을 각각 추출하기
   , substring(dt,1,4) as year
   , substring(dt,6,2) as month
   , substring(dt,9,2) as date
   , sum(purchase_amount) as purchase_amount
	,count(order_id) as orders
	from purchase_log
	group by dt
	)
	select
	*
	from
	  daily_purchase
	order by dt
	;

-- 9-4 날짜별 매출을 일시 테이블로 만드는 쿼리
with
daily_purchase as (
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
	select
	*
	from
	 daily_purchase
	order by dt
	;
	
-- 9-5 daily_purchase 테이블에 대해 당월 누계 매출을 집계하는 쿼리
with
daily_purchase as (
  select
	dt
	, substring(dt, 1, 4) as year
	, substring(dt, 6, 2) as month
	, substring(dt, 9, 2) as date
    , sum(purchase_amount) as purchase_amount
    , count(order_id) as orders
   from purchase_log
   group by dt
)
 select
  *
 from
  daily_purchase
  order by dt
  ;