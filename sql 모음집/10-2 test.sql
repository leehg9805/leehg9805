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


-- 10-3 매출 구성비누계와 ABC 등급을 계산하는 쿼리
WITH
monthly_sales as(
 select
	category as category1
	-- 항목별 매출 계산하기
	, sum(price) as amount
  from
	purchase_detail_log
	-- 대상 1개월 동안의 로그를 조건으로 걸기
	where
	 dt between '2017-01-01' and '2017-01-31'
	group by
	 category
	
)
 , sales_composition_ratio as(
   select
    category1
	 , amount
	 
	 
	 -- 구성비: 100.0*<항목별 매출>/<전체 매출>
	 , 100.0* amount/sum(amount) over() as composition
	 
	 -- 구성비 누계: 100*<항목별 구계 매출>/ <전체 매출>
	 ,100.0*sum(amount) over(order by amount desc
							rows between unbounded preceding and current row)
	 /sum(amount) over() as cumulative_ratio
	 from
	  monthly_sales
 )
 select
 *
 -- 구성비누계 범위에 따라 순위를 붙이기
 , case
   when cumulative_ratio between 0 and 70 then 'A'
   when cumulative_ratio between 70 and 90 then 'B'
   when cumulative_ratio between 90 and 100 then 'C'
   end as abc_rank
  from
   sales_composition_ratio
   order by
    amount desc
	;
 