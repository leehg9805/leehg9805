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


-- 23-5 사용자끼리의 유사도를 계산
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
, user_base_normalized_ratings as (
  -- 사용자 벡터 정규화하기
  select 
	 user_id
	,product
	,score
	  -- partition by user_id로 사용자별 벡터 노름 계산
	, SQRT(sum(score*score) over(partition by user_id)) as norm
	, score/sqrt(sum(score*score) over(partition by user_id)) as norm_score
 from
	 ratings
)
, related_users as (
   -- 경향이 비슷한 사용자 찾기
	select 
	 r1.user_id
	,r2.user_id as related_user
	,count(r1.product) as products
	,sum(r1.norm_score*r2.norm_score) as score
	,row_number()
	   over(partition by r1.user_id order by sum(r1.norm_score*r2.norm_score) desc)
	as rank
	from 
	 user_base_normalized_ratings as r1
	join
	 user_base_normalized_ratings as r2
	 on r1.product = r2.product
	where
	 r1.user_id<>r2.user_id
	group by
	 r1.user_id, r2.user_id
)
select *
from
 related_users
 order by
  user_id, rank
  ;


-- 23-6 순위가 높은 유사 사용자를 기반으로 추천 아이템을 추출하는 쿼리
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
, user_base_normalized_ratings as (
  -- 사용자 벡터 정규화하기
  select 
	 user_id
	,product
	,score
	  -- partition by user_id로 사용자별 벡터 노름 계산
	, SQRT(sum(score*score) over(partition by user_id)) as norm
	, score/sqrt(sum(score*score) over(partition by user_id)) as norm_score
 from
	 ratings
)
, related_users as (
   -- 경향이 비슷한 사용자 찾기
	select 
	 r1.user_id
	,r2.user_id as related_user
	,count(r1.product) as products
	,sum(r1.norm_score*r2.norm_score) as score
	,row_number()
	   over(partition by r1.user_id order by sum(r1.norm_score*r2.norm_score) desc)
	as rank
	from 
	 user_base_normalized_ratings as r1
	join
	 user_base_normalized_ratings as r2
	 on r1.product = r2.product
	where
	 r1.user_id<>r2.user_id
	group by
	 r1.user_id, r2.user_id
)
, related_user_base_products as (
  select 
	 u.user_id
	,r.product
	,sum(u.score*r.score) as score
	,row_number()
	   over(partition by u.user_id order by sum(u.score*r.score)desc)
	as rank
	from
	 related_users as u
	join
	 ratings as r
	 on u.related_user = r.user_id
    where
	 u.rank <=1
	group by
	 u.user_id, r.product
)
select *
from
 related_user_base_products
order by
 user_id
 ;
 
-- 23-7 이미 구매한 아이템을 필터링하는 쿼리
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
, user_base_normalized_ratings as (
  -- 사용자 벡터 정규화하기
  select 
	 user_id
	,product
	,score
	  -- partition by user_id로 사용자별 벡터 노름 계산
	, SQRT(sum(score*score) over(partition by user_id)) as norm
	, score/sqrt(sum(score*score) over(partition by user_id)) as norm_score
 from
	 ratings
)
, related_users as (
   -- 경향이 비슷한 사용자 찾기
	select 
	 r1.user_id
	,r2.user_id as related_user
	,count(r1.product) as products
	,sum(r1.norm_score*r2.norm_score) as score
	,row_number()
	   over(partition by r1.user_id order by sum(r1.norm_score*r2.norm_score) desc)
	as rank
	from 
	 user_base_normalized_ratings as r1
	join
	 user_base_normalized_ratings as r2
	 on r1.product = r2.product
	where
	 r1.user_id<>r2.user_id
	group by
	 r1.user_id, r2.user_id
)
, related_user_base_products as (
  select 
	 u.user_id
	,r.product
	,sum(u.score*r.score) as score
	,row_number()
	   over(partition by u.user_id order by sum(u.score*r.score)desc)
	as rank
	from
	 related_users as u
	join
	 ratings as r
	 on u.related_user = r.user_id
    where
	 u.rank <=1
	group by
	 u.user_id, r.product
)
select 
 p.user_id
 ,p.product
 ,p.score
 ,row_number()
    over(partition by p.user_id order by p.score desc)
   as rank
  from
   related_user_base_products as p
   left join
    ratings as r
	on p.user_id = r.user_id
	and p.product =r.product
 where
  -- 대상 사용자가 구매하지 않은 상품만 추천
  coalesce(r.purchase_count, 0) = 0
  order by
   p.user_id
   ;