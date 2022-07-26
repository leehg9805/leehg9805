DROP TABLE IF EXISTS purchase_detail_log;
CREATE TABLE purchase_detail_log(
    dt           varchar(255)
  , order_id     integer
  , user_id      varchar(255)
  , item_id      varchar(255)
  , price        integer
  , category     varchar(255)
  , sub_category varchar(255)
);

INSERT INTO purchase_detail_log
VALUES
    ('2017-01-18', 48291, 'usr33395', 'lad533', 37300,  'ladys_fashion', 'bag')
  , ('2017-01-18', 48291, 'usr33395', 'lad329', 97300,  'ladys_fashion', 'jacket')
  , ('2017-01-18', 48291, 'usr33395', 'lad102', 114600, 'ladys_fashion', 'jacket')
  , ('2017-01-18', 48291, 'usr33395', 'lad886', 33300,  'ladys_fashion', 'bag')
  , ('2017-01-18', 48292, 'usr52832', 'dvd871', 32800,  'dvd'          , 'documentary')
  , ('2017-01-18', 48292, 'usr52832', 'gam167', 26000,  'game'         , 'accessories')
  , ('2017-01-18', 48292, 'usr52832', 'lad289', 57300,  'ladys_fashion', 'bag')
  , ('2017-01-18', 48293, 'usr28891', 'out977', 28600,  'outdoor'      , 'camp')
  , ('2017-01-18', 48293, 'usr28891', 'boo256', 22500,  'book'         , 'business')
  , ('2017-01-18', 48293, 'usr28891', 'lad125', 61500,  'ladys_fashion', 'jacket')
  , ('2017-01-18', 48294, 'usr33604', 'mem233', 116300, 'mens_fashion' , 'jacket')
  , ('2017-01-18', 48294, 'usr33604', 'cd477' , 25800,  'cd'           , 'classic')
  , ('2017-01-18', 48294, 'usr33604', 'boo468', 31000,  'book'         , 'business')
  , ('2017-01-18', 48294, 'usr33604', 'foo402', 48700,  'food'         , 'meats')
  , ('2017-01-18', 48295, 'usr38013', 'foo134', 32000,  'food'         , 'fish')
  , ('2017-01-18', 48295, 'usr38013', 'lad147', 96100,  'ladys_fashion', 'jacket')
 ;

-- 10-5 최댓값, 최솟값, 범위를 구하는 쿼리
with
stats as(
select
    -- 금액의 최댓값
	max(price) as max_price
	-- 금액의 최솟값
	, min(price) as min_price
	-- 금액의 범위
	, max(price)-min(price) as range_price
	 -- 계층 수
	, 10 as bucket_num
	from
	 purchase_detail_log
	
)
select *
from stats
;

-- 10-6 데이터의 계층을 구하는 쿼리
with
stats as(
select
	-- 금액의 최댓값
	max(price) as max_price
	-- 금액의 최솟값
	, min(price) as min_price
	-- 금액의 범위
	, max(price)-min(price) as range_price
	-- 계층 수
	, 10 as bucket_num
	from
	 purchase_detail_log
) 
, purchase_log_with_bucket as(
select
	price
	,min_price
	-- 정규화 금액: 대상 금액에서 최소 금액을 뺀 것
	, price-min_price as diff
	 -- 계층 범위: 금액 범위를 계층 수로 나눈 것
	, 1.0 * range_price/bucket_num as bucket_range
	
	-- 계층 판정: FLOOR(<정규화 금액>/<계층 범위>)
	, Floor(
	   1.0*(price-min_price)
	    /(1.0*range_price/bucket_num)
	     -- index가 1부터 시작하므로 1만큼 더하기
	) + 1 as bucket
	
	-- PostgreSQL의 경우 width_bucket 함수 사용 가능
	, width_bucket(price, min_price, max_price, bucket_num) as bucket
	from
	 purchase_detail_log, stats
	 )
	 select*
	 from purchase_log_with_bucket
	 order by price
	 ;
	 
-- 10-7 계급 상한 값을 조정한 쿼리
with
stats as(
select
	--<금액의 최댓값>+1
	MAX(price) + 1 as max_price
	-- 금액의 최솟값
	,MIN(price) as min_price
	-- <금액의 범위>+1(실수)
	, MAX(price) + 1 -MIN(price) as range_price
	 -- 계층수
	,10 as bucket_num
	from
	 purchase_detail_log
	)
	, purchase_log_with_bucket as (
    select
	price
	,min_price
	-- 정규화 금액: 대상 금액에서 최소 금액을 뺀 것
	, price-min_price as diff
	 -- 계층 범위: 금액 범위를 계층 수로 나눈 것
	, 1.0 * range_price/bucket_num as bucket_range
	
	-- 계층 판정: FLOOR(<정규화 금액>/<계층 범위>)
	, Floor(
	   1.0*(price-min_price)
	    /(1.0*range_price/bucket_num)
	     -- index가 1부터 시작하므로 1만큼 더하기
	) + 1 as bucket
	
	-- PostgreSQL의 경우 width_bucket 함수 사용 가능
	, width_bucket(price, min_price, max_price, bucket_num) as bucket
	from
	 purchase_detail_log, stats
		
	)
		
		select *
		from purchase_log_with_bucket
		order by price
		;

-- 10-8 히스토그램을 구하는 쿼리
with
stats as (
select
	max(price)+ 1 as max_price
	, min(price) as min_price
	, max(price)+1 - min(price) as range_price
	, 10 as bucket_num
	from
	 purchase_detail_log
	)
	, purchase_log_with_bucket as (
	  select
		price
		, min_price
		, price - min_price as diff
		, 1.0*range_price/bucket_num as bucket_range
		
		, floor(
		  1.0*(price - min_price)
			/(1.0*range_price/bucket_num)
		)+ 1 
		, width_bucket(price, min_price, max_price, bucket_num) as bucket
		from
		  purchase_detail_log, stats
	)
	select bucket
	   -- 계층의 하한과 상한 계산하기
	   , min_price+bucket_range*(bucket-1) as lower_limit
	   , min_price+bucket_range*bucket as upper_limit
	     -- 도수세기
	   , count(price) as num_purchase
	     -- 합계 금액 계산하기
	   , sum(price) as total_amount
	   from
	    purchase_log_with_bucket
	   group by
	    bucket, min_price, bucket_range
	   order by bucket
	   ;

-- 10-9 히스토그램의 상한과 하한을 수동으로 조정한 쿼리
WITH
stats as(
select
	-- 금액의 최댓값
	5000 as max_price
	-- 금액의 최솟값
	, 0 as min_price
	-- 금액의 범위
	, 50000 as range_price
	-- 계층 수
	, 10 as bucket_num
	from
	 purchase_detail_log
)
, purchase_log_with_bucket as(
select
	  price
	, min_price
	, price-min_price as diff
	, 1.0*range_price/bucket_num as bucket_range
	
	, floor(
	1.0*(price-min_price)
		/(1.0*range_price/bucket_num)
	) + 1 as bucket
	FROM
	 purchase_detail_log, stats
)
select
  bucket
  ,min_price + bucket_range*(bucket - 1) as lower_limit
  ,min_price + bucket_range*bucket as upper_limit
  ,count(price) as num_purchase
  ,sum(price) as total_amount
  from
   purchase_log_with_bucket
   group by
   bucket, min_price, bucket_range
   order by bucket
   ;


