DROP TABLE IF EXISTS review;
CREATE TABLE review (
    user_id    varchar(255)
  , product_id varchar(255)
  , score      numeric
);

INSERT INTO review
VALUES
    ('U001', 'A001', 4.0)
  , ('U001', 'A002', 5.0)
  , ('U001', 'A003', 5.0)
  , ('U002', 'A001', 3.0)
  , ('U002', 'A002', 3.0)
  , ('U002', 'A003', 4.0)
  , ('U003', 'A001', 5.0)
  , ('U003', 'A002', 4.0)
  , ('U003', 'A003', 4.0)
;

-- 집약 함수를 사용해서 테이블 전체의 특징량을 계산하는 쿼리
select
   count(*) as total_count
   ,count(distinct user_id) as user_count
   ,count(distinct product_id) as product_count
   ,sum(score) as sum
   ,avg(score) as avg
   ,max(score) as max
   ,min(score) as min
from
  review
  ;

-- 사용자 기반으로 데이터를 분할하고 집약 함수를 적용하는 쿼리
select
    user_id
	,count(*) as total_count
	,count(distinct product_id) as product_count
	,sum(score) as sum
	,avg(score) as avg
	,max(score) as max
	,min(score) as min
from 
    review
group by 
    user_id
;

-- 윈도 함수를 사용해 집약 함수의 결과와 원래 값을 동시에 다루는 쿼리
select
  user_id
  ,product_id
    -- 개별 리뷰 점수
  ,score
   -- 전체 평균 리뷰 점수
  ,avg(score) over(partition by user_id) as user_avg_score
   -- 개별 리뷰 점수와 사용자 평균 리뷰 점수의 차이
  ,score - avg(score) over(partition by user_id) as user_avg_score_diff
from
  review
 ;