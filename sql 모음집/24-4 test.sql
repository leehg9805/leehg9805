DROP TABLE IF EXISTS action_counts_with_date;
CREATE TABLE action_counts_with_date(
    dt      varchar(255)
  , user_id varchar(255)
  , product varchar(255)
  , v_count integer
  , p_count integer
);

INSERT INTO action_counts_with_date
VALUES
    ('2016-10-03', 'U001', 'D001',  1, 0)
  , ('2016-11-03', 'U001', 'D001',  1, 1)
  , ('2016-10-03', 'U001', 'D002', 16, 0)
  , ('2016-10-03', 'U001', 'D003', 14, 0)
  , ('2016-10-03', 'U001', 'D004', 15, 0)
  , ('2016-10-03', 'U001', 'D005', 19, 0)
  , ('2016-10-25', 'U001', 'D005',  1, 0)
  , ('2016-11-03', 'U001', 'D005',  1, 0)
  , ('2016-11-05', 'U001', 'D005',  0, 1)
  , ('2016-10-03', 'U002', 'D001', 10, 0)
  , ('2016-11-30', 'U002', 'D001',  0, 1)
  , ('2016-11-20', 'U002', 'D003', 28, 0)
  , ('2016-11-20', 'U002', 'D005', 28, 0)
  , ('2016-11-30', 'U002', 'D005',  0, 1)
  , ('2016-11-01', 'U003', 'D001', 49, 0)
  , ('2016-11-01', 'U003', 'D004', 29, 0)
  , ('2016-11-03', 'U003', 'D004',  0, 1)
  , ('2016-11-01', 'U003', 'D005', 24, 0)
  , ('2016-12-01', 'U003', 'D005',  0, 1)
;

-- 24-9 사용자들의 최종 접근일과 각 레코드와의 날짜 차이를 계산하는 쿼리
with
action_counts_with_diff_date as(
 select *
	-- 사용자별로 최종 접근일과 각 레코드의 날짜 차이 계산하기
	,max(dt::date) over(partition by user_id) as last_access
	,max(dt::date) over(partition by user_id) -dt::date as diff_date
	from
	 action_counts_with_date
)
select *
from action_counts_with_diff_date;

-- 24-10 날짜 차이에 따른 가중치를 계산하는 쿼리
with
action_counts_with_diff_date as(
 select *
	-- 사용자별로 최종 접근일과 각 레코드의 날짜 차이 계산하기
	,max(dt::date) over(partition by user_id) as last_access
	,max(dt::date) over(partition by user_id) -dt::date as diff_date
	from
	 action_counts_with_date
), action_counts_with_weight as (
   select *
	-- 날짜 차이에 가중치 계산하기(매개 변수 a =0.1)
	, 1.0/log(2, 0.1*diff_date +2) as weight
	from action_counts_with_diff_date
)
select 
  user_id
  ,product
  ,v_count
  ,p_count
  ,diff_date
  ,weight
  from action_counts_with_weight
  order by
   user_id, product, diff_date desc
   ;
   
-- 24-11 일수차에 따른 중첩을 사용해 열람 수와 구매 수 점수를 계산하는 쿼리
with
action_counts_with_diff_date as(
 select *
	-- 사용자별로 최종 접근일과 각 레코드의 날짜 차이 계산하기
	,max(dt::date) over(partition by user_id) as last_access
	,max(dt::date) over(partition by user_id) -dt::date as diff_date
	from
	 action_counts_with_date
), action_counts_with_weight as (
   select *
	-- 날짜 차이에 가중치 계산하기(매개 변수 a =0.1)
	, 1.0/log(2, 0.1*diff_date +2) as weight
	from action_counts_with_diff_date
)
, action_scores as (
  select 
	  user_id
	, product
	, sum(v_count) as v_count
	, sum(v_count * weight) as v_score
	, sum(p_count) as p_count
	, sum(p_count * weight) as p_score
 from action_counts_with_weight
 group by
	 user_id, product
)
select *
from action_scores
order by
 user_id, product;
 
