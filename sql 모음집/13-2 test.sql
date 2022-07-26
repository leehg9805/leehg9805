DROP TABLE IF EXISTS action_log;
CREATE TABLE action_log(
    dt       varchar(255)
  , session  varchar(255)
  , user_id  varchar(255)
  , action   varchar(255)
  , products varchar(255)
  , stamp    varchar(255)
);

INSERT INTO action_log
VALUES
    ('2016-11-03', 'A', 'U001', 'add_cart', '1'    , '2016-11-03 18:00:00')
  , ('2016-11-03', 'A', 'U001', 'add_cart', '2'    , '2016-11-03 18:01:00')
  , ('2016-11-03', 'A', 'U001', 'add_cart', '3'    , '2016-11-03 18:02:00')
  , ('2016-11-03', 'A', 'U001', 'purchase', '1,2,3', '2016-11-03 18:10:00')
  , ('2016-11-03', 'B', 'U002', 'add_cart', '1'    , '2016-11-03 19:00:00')
  , ('2016-11-03', 'B', 'U002', 'purchase', '1'    , '2016-11-03 20:00:00')
  , ('2016-11-03', 'B', 'U002', 'add_cart', '2'    , '2016-11-03 20:30:00')
  , ('2016-11-04', 'C', 'U001', 'add_cart', '4'    , '2016-11-04 12:00:00')
  , ('2016-11-04', 'C', 'U001', 'add_cart', '5'    , '2016-11-04 12:00:00')
  , ('2016-11-04', 'C', 'U001', 'add_cart', '6'    , '2016-11-04 12:00:00')
  , ('2016-11-04', 'D', 'U002', 'purchase', '2'    , '2016-11-04 13:00:00')
  , ('2016-11-04', 'D', 'U001', 'purchase', '5,6'  , '2016-11-04 15:00:00')
;


-- 13-4 상품들이 카트에 추가된 시각과 구매된 시각을 산출하는 쿼리
with
row_action_log as(
  select
	dt
	, user_id
	, action
	-- 쉼표로 구분된 product_id 리스트 전개하기
	, regexp_split_to_table(products, ',') as product_id
	, stamp
	from 
	 action_log
)
, action_time_stats as (
   -- 사용자와 상품 조합의 카드 추가 시간과 구매 시간 추출
	select
	 user_id
	,product_id
	,min(case action when 'add_cart' then dt end) as dt
	,min(case action when 'add_cart' then stamp end) as add_cart_time
	,min(case action when 'purchase' then stamp end) as purchase_time
	,extract(epoch from
			min(case action when 'purchase' then stamp::timestamp end)
			 - min(case action when 'add_cart' then stamp::timestamp end))
	as lead_time
	
	from
	  row_action_log
	group by
	  user_id,product_id
)
select
   user_id
   , product_id
   , add_cart_time
   , purchase_time
   , lead_time
   from
    action_time_stats
   order by
     user_id, product_id
	 ;
	 
-- 13-5 카트 추가 후 n시간 이내에 구매된 상품 수와 구매율을 집계하는 쿼리
with
row_action_log as(
  select
	dt
	, user_id
	, action
	-- 쉼표로 구분된 product_id 리스트 전개하기
	, regexp_split_to_table(products, ',') as product_id
	, stamp
	from 
	 action_log
)
, action_time_stats as (
   -- 사용자와 상품 조합의 카드 추가 시간과 구매 시간 추출
	select
	 user_id
	,product_id
	,min(case action when 'add_cart' then dt end) as dt
	,min(case action when 'add_cart' then stamp end) as add_cart_time
	,min(case action when 'purchase' then stamp end) as purchase_time
	,extract(epoch from
			min(case action when 'purchase' then stamp::timestamp end)
			 - min(case action when 'add_cart' then stamp::timestamp end))
	as lead_time
	
	from
	  row_action_log
	group by
	  user_id,product_id
)
, purchase_lead_time_flag as (
 select
	user_id
	, product_id
	, dt
	, case when lead_time <= 1*60*60 then 1 else 0 end as purchase_1_hour
	, case when lead_time <= 6*60*60 then 1 else 0 end as purchase_6_hours
	, case when lead_time <= 24*60*60 then 1 else 0 end as purchase_24_hours
	, case when lead_time <= 48*60*60 then 1 else 0 end as purchase_48_hours
	, case when lead_time is null or not (lead_time <= 48*60*60) then 1
	ELSE 0
	end as not_purchase
	from
	 action_time_stats
	)
	select 
	   dt
	   , count(*) as add_cart
	   , sum(purchase_1_hour) as purchase_1_hour
	   , avg(purchase_1_hour) as purchase_1_hour_rate
	   , sum(purchase_6_hours) as purchase_6_hours
	   , avg(purchase_6_hours) as purchase_6_hours_rate
	   , sum(purchase_24_hours) as purchase_24_hours
	   , avg(purchase_24_hours) as purchase_24_hours_rate
	   , sum(purchase_48_hours) as purchase_48_hours
	   , avg(purchase_48_hours) as purchase_48_hours_rate
	   , sum(not_purchase)      as not_purchase
	   , avg(not_purchase)      as not_purchase_rate
	   from
	    purchase_lead_time_flag
	  group by
	    dt
		;
		
		
		