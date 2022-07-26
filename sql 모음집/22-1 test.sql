DROP TABLE IF EXISTS purchase_detail_log;
CREATE TABLE purchase_detail_log(
    stamp       varchar(255)
  , session     varchar(255)
  , purchase_id integer
  , product_id  varchar(255)
);

INSERT INTO purchase_detail_log
  VALUES
    ('2016-11-03 18:10', '989004ea',  1, 'D001')
  , ('2016-11-03 18:10', '989004ea',  1, 'D002')
  , ('2016-11-03 20:00', '47db0370',  2, 'D001')
  , ('2016-11-04 13:00', '1cf7678e',  3, 'D002')
  , ('2016-11-04 15:00', '5eb2e107',  4, 'A001')
  , ('2016-11-04 15:00', '5eb2e107',  4, 'A002')
  , ('2016-11-04 16:00', 'fe05e1d8',  5, 'A001')
  , ('2016-11-04 16:00', 'fe05e1d8',  5, 'A003')
  , ('2016-11-04 17:00', '87b5725f',  6, 'A001')
  , ('2016-11-04 17:00', '87b5725f',  6, 'A003')
  , ('2016-11-04 17:00', '87b5725f',  6, 'A004')
  , ('2016-11-04 18:00', '5d5b0997',  7, 'A005')
  , ('2016-11-04 18:00', '5d5b0997',  7, 'A006')
  , ('2016-11-04 19:00', '111f2996',  8, 'A002')
  , ('2016-11-04 19:00', '111f2996',  8, 'A003')
  , ('2016-11-04 20:00', '3efe001c',  9, 'A001')
  , ('2016-11-04 20:00', '3efe001c',  9, 'A003')
  , ('2016-11-04 21:00', '9afaf87c', 10, 'D001')
  , ('2016-11-04 21:00', '9afaf87c', 10, 'D003')
  , ('2016-11-04 22:00', 'd45ec190', 11, 'D001')
  , ('2016-11-04 22:00', 'd45ec190', 11, 'D002')
  , ('2016-11-04 23:00', '36dd0df7', 12, 'A002')
  , ('2016-11-04 23:00', '36dd0df7', 12, 'A003')
  , ('2016-11-04 23:00', '36dd0df7', 12, 'A004')
  , ('2016-11-05 15:00', 'cabf98e8', 13, 'A002')
  , ('2016-11-05 15:00', 'cabf98e8', 13, 'A004')
  , ('2016-11-05 16:00', 'f3b47933', 14, 'A005')
;

-- 22-1 구매 로그 수와 상품별 구매 수를 세는 쿼리
with
purchase_id_count as (
  -- 구매 상세 로그에서 유니크한 구매 로그 수 계산
	select count(distinct purchase_id) as purchase_count
	from purchase_detail_log
)
, purchase_detail_log_with_counts as (
  select 
	 d.purchase_id
	, p.purchase_count
	, d.product_id
	 -- 상품별 구매 수 계산하기
	, count(1) over(partition by d.product_id) as product_count
	from
	 purchase_detail_log as d
	cross join 
	 -- 구매 로그 수를 모든 레코드 수와 결합
	purchase_id_count as p
	
)
select 
 *
 from
 purchase_detail_log_with_counts
 order by
  product_id, purchase_id
  ;


-- 22-2 상품 조합별로 구매 수를 세는 쿼리
with
purchase_id_count as (
  -- 구매 상세 로그에서 유니크한 구매 로그 수 계산
	select count(distinct purchase_id) as purchase_count
	from purchase_detail_log
)
, purchase_detail_log_with_counts as (
  select 
	 d.purchase_id
	, p.purchase_count
	, d.product_id
	 -- 상품별 구매 수 계산하기
	, count(1) over(partition by d.product_id) as product_count
	from
	 purchase_detail_log as d
	cross join 
	 -- 구매 로그 수를 모든 레코드 수와 결합
	purchase_id_count as p
	
)
, product_pair_with_stat as (
  select 
	 l1.product_id as p1
	,l2.product_id as p2
	,l1.product_count as p1_count
	,l2.product_count as p2_count
	, count(1) as p1_p2_count
	,l1.purchase_count as purchase_count
	from
	 purchase_detail_log_with_counts as l1
	join
	 purchase_detail_log_with_counts as l2
	on l1.purchase_id = l2.purchase_id
	where
	 -- 같은 상품 조합 제외
	l1.product_id<>l2.product_id
	group by
	 l1.product_id
	,l2.product_id
	,l1.product_count
	,l2.product_count
	,l1.purchase_count
	
)
select 
*
from
 product_pair_with_stat
 order by
 p1,p2
 ;
 
-- 22-3 지지도, 확신도, 리포트를 계산하는 쿼리
with
purchase_id_count as (
  -- 구매 상세 로그에서 유니크한 구매 로그 수 계산
	select count(distinct purchase_id) as purchase_count
	from purchase_detail_log
)
, purchase_detail_log_with_counts as (
  select 
	 d.purchase_id
	, p.purchase_count
	, d.product_id
	 -- 상품별 구매 수 계산하기
	, count(1) over(partition by d.product_id) as product_count
	from
	 purchase_detail_log as d
	cross join 
	 -- 구매 로그 수를 모든 레코드 수와 결합
	purchase_id_count as p
	
)
, product_pair_with_stat as (
  select 
	 l1.product_id as p1
	,l2.product_id as p2
	,l1.product_count as p1_count
	,l2.product_count as p2_count
	, count(1) as p1_p2_count
	,l1.purchase_count as purchase_count
	from
	 purchase_detail_log_with_counts as l1
	join
	 purchase_detail_log_with_counts as l2
	on l1.purchase_id = l2.purchase_id
	where
	 -- 같은 상품 조합 제외
	l1.product_id<>l2.product_id
	group by
	 l1.product_id
	,l2.product_id
	,l1.product_count
	,l2.product_count
	,l1.purchase_count
	
)
select 
p1 
,p2
, 100.0*p1_p2_count/purchase_count as support
, 100.0*p1_p2_count/p1_count as confidence
, (100.0*p1_p2_count / p1_count)
  /(100.0*p2_count/purchase_count) as lift
  from
   product_pair_with_stat
   order by
    p1,p2
	;

