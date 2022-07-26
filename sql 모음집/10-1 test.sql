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


-- 10-1 카테고리별 매출과 소계를 동시에 구하는 쿼리
with
sub_category_amount as (
  -- 소 카테고리의 매출 집계
  select
	category as category
	, sub_category as sub_category
	, sum(price) as amount
	from
	 purchase_detail_log
	group by
	  category, sub_category
	)
	,category_amount as (
	-- 대카테고리의 매출 집계
	select 
		 category
		,'all' as sub_category
		,sum(price) as amount
		from
		 purchase_detail_log
		group by
		 category
		)
	, total_amount as (
	-- 전체 매출 집계
	select
		 'all' as category
		, 'all' as sub_category
		, sum(price) as amount
		from
		 purchase_detail_log
		)
		   select category, sub_category, amount from sub_category_amount
		   union all select category, sub_category, amount from category_amount
		   union all select category, sub_category, amount from total_amount
		   ;

-- 10-2 Rollup을 사용한 카테고리별 매출과 소계를 동시에 구하기
select
   coalesce(category,'all') as category
   , coalesce(sub_category, 'all') as sub_category
   , sum(price) as amount
   from
    purchase_detail_log
   group by 
     rollup(category, sub_category)
	 ;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


