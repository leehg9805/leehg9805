DROP TABLE IF EXISTS action_log;
CREATE TABLE action_log(
    stamp   varchar(255)
  , user_id varchar(255)
  , action  varchar(255)
  , product varchar(255)
);

INSERT INTO action_log
VALUES
    ('2016-11-03 18:00:00', 'U001', 'view'    , 'D001')
  , ('2016-11-03 18:01:00', 'U001', 'view'    , 'D002')
  , ('2016-11-03 18:02:00', 'U001', 'view'    , 'D003')
  , ('2016-11-03 18:03:00', 'U001', 'view'    , 'D004')
  , ('2016-11-03 18:04:00', 'U001', 'view'    , 'D005')
  , ('2016-11-03 18:05:00', 'U001', 'view'    , 'D001')
  , ('2016-11-03 18:06:00', 'U001', 'view'    , 'D005')
  , ('2016-11-03 18:10:00', 'U001', 'purchase', 'D001')
  , ('2016-11-03 18:10:00', 'U001', 'purchase', 'D005')
  , ('2016-11-03 19:00:00', 'U002', 'view'    , 'D001')
  , ('2016-11-03 19:01:00', 'U002', 'view'    , 'D003')
  , ('2016-11-03 19:02:00', 'U002', 'view'    , 'D005')
  , ('2016-11-03 19:03:00', 'U002', 'view'    , 'D003')
  , ('2016-11-03 19:04:00', 'U002', 'view'    , 'D005')
  , ('2016-11-03 19:10:00', 'U002', 'purchase', 'D001')
  , ('2016-11-03 19:10:00', 'U002', 'purchase', 'D005')
  , ('2016-11-03 20:00:00', 'U003', 'view'    , 'D001')
  , ('2016-11-03 20:01:00', 'U003', 'view'    , 'D004')
  , ('2016-11-03 20:02:00', 'U003', 'view'    , 'D005')
  , ('2016-11-03 20:10:00', 'U003', 'purchase', 'D004')
  , ('2016-11-03 20:10:00', 'U003', 'purchase', 'D005')
;

-- 23-1 열람 수와 구매 수를 조합한 점수를 계산하는 쿼리
with
ratings as (
  select 
	 user_id
	, product
	
	 -- 상품 열람 수
	, sum(case when action = 'view'  then 1 else 0 end) as view_count
	
	-- 상품 구매 수
	, sum(case when action = 'purchase' then 1 else 0 end) as purchase_count
	
	-- 열람 수 와 구매 수에 3:7의 비율의 가중치 주어 평균 구하기
	, 0.3*sum(case when action ='view' then 1 else 0 end)
	 + 0.7*sum(case when action = 'purchase' then 1 else 0 end)
	 as score
 from
	action_log
 group by 
	user_id, product
)
select *
from
 ratings
order by
 user_id, score desc
 ;
 

-- 23-2 아이템 사이의 유사도를 계산하고 순위를 생성하는 쿼리
with
ratings as (
select 
	 user_id
	, product
	
	 -- 상품 열람 수
	, sum(case when action = 'view'  then 1 else 0 end) as view_count
	
	-- 상품 구매 수
	, sum(case when action = 'purchase' then 1 else 0 end) as purchase_count
	
	-- 열람 수 와 구매 수에 3:7의 비율의 가중치 주어 평균 구하기
	, 0.3*sum(case when action ='view' then 1 else 0 end)
	 + 0.7*sum(case when action = 'purchase' then 1 else 0 end)
	 as score
 from
	action_log
 group by 
	user_id, product
)
select 
 r1.product as target
 , r2.product as related
   -- 모든 아이템을 열람/구매한 사용자 수
 , count(r1.user_id) as users
  -- 스코어들을 곱하고 합계를 구해 유사도 계산
 , sum(r1.score*r2.score) as score
  -- 상품의 유사도 순위 구하기
 , row_number()
     over(partition by r1.product order by sum(r1.score*r2.score) desc)
	 as rank
	from
	 ratings as r1
	join
	 ratings as r2
	  -- 공통 사용자가 존재하는 상품의 페어 만들기
	  on r1.user_id = r2.user_id
	 where
	  -- 같은 아이템의 경우에는 페어 제외
	  r1.product <> r2.product 
	 group by 
	  r1.product, r2.product 
	 order by
	  target, rank
	  ;
	  

-- 23-3 아이템 벡터를 L2 정규화
with
ratings as (
select 
	 user_id
	, product
	
	 -- 상품 열람 수
	, sum(case when action = 'view'  then 1 else 0 end) as view_count
	
	-- 상품 구매 수
	, sum(case when action = 'purchase' then 1 else 0 end) as purchase_count
	
	-- 열람 수 와 구매 수에 3:7의 비율의 가중치 주어 평균 구하기
	, 0.3*sum(case when action ='view' then 1 else 0 end)
	 + 0.7*sum(case when action = 'purchase' then 1 else 0 end)
	 as score
 from
	action_log
 group by 
	user_id, product
)
, product_base_normalized_ratings as (
   -- 아이템 벡터 정규화하기
  select 
	user_id
	,product
	,score
	,sqrt(sum(score*score) over(partition by product)) as norm
	,score / sqrt(sum(score*score) over(partition by product)) as norm_score
   from
	 ratings
)
select *
from
 product_base_normalized_ratings
 ;
 
 
-- 23-4 정규화된 점수로 아이템의 유사도를 계산하는 쿼리
with
ratings as (
select 
	 user_id
	, product
	
	 -- 상품 열람 수
	, sum(case when action = 'view'  then 1 else 0 end) as view_count
	
	-- 상품 구매 수
	, sum(case when action = 'purchase' then 1 else 0 end) as purchase_count
	
	-- 열람 수 와 구매 수에 3:7의 비율의 가중치 주어 평균 구하기
	, 0.3*sum(case when action ='view' then 1 else 0 end)
	 + 0.7*sum(case when action = 'purchase' then 1 else 0 end)
	 as score
 from
	action_log
 group by 
	user_id, product
)
, product_base_normalized_ratings as (
   -- 아이템 벡터 정규화하기
  select 
	user_id
	,product
	,score
	,sqrt(sum(score*score) over(partition by product)) as norm
	,score / sqrt(sum(score*score) over(partition by product)) as norm_score
   from
	 ratings
)
select 
 r1.product as target
 , r2.product as related
  -- 모든 아이템을 열람/ 구매한 사용자 수
 , count(r1.user_id) as users
   -- 스코어들을 곱하고 합계를 구해 유사도 계산
 , sum(r1.score*r2.score) as score
 , sum(r1.norm_score*r2.score) as score
   -- 상품의 유사도 순위 구하기
 , row_number()
    over(partition by r1.product order by sum(r1.norm_score* r2.norm_score) desc)
	as rank
  from
   product_base_normalized_ratings as r1
   join 
    product_base_normalized_ratings as r2
	 -- 공통 사용자가 존재하면 상품 페어 만들기
	 on r1.user_id = r2.user_id
	group by
	 r1.product, r2.product
	order by
	 target, rank
	 ;
