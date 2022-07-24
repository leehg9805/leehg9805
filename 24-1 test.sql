DROP TABLE IF EXISTS search_evaluation_by_col;
CREATE TABLE search_evaluation_by_col(
    path      varchar(255)
  , recall    numeric
  , precision numeric
);

INSERT INTO search_evaluation_by_col
VALUES
    ('/search1', 40.0, 60.0)
  , ('/search2', 60.0, 40.0)
  , ('/search3', 50.0, 50.0)
  , ('/search4', 30.0, 60.0)
  , ('/search5', 70.0,  0.0)
;

DROP TABLE IF EXISTS search_evaluation_by_row;
CREATE TABLE search_evaluation_by_row(
    path  varchar(255)
  , index varchar(255)
  , value numeric
);

INSERT INTO search_evaluation_by_row
VALUES
    ('/search1', 'recall'   , 40.0)
  , ('/search1', 'precision', 60.0)
  , ('/search2', 'recall'   , 60.0)
  , ('/search2', 'precision', 40.0)
  , ('/search3', 'recall'   , 50.0)
  , ('/search3', 'precision', 50.0)
  , ('/search4', 'recall'   , 30.0)
  , ('/search4', 'precision', 60.0)
  , ('/search5', 'recall'   , 70.0)
  , ('/search5', 'precision',  0.0)
;

-- 24-1 세로 데이터의 평균을 구하는 쿼리
select 
 *
 -- 산술 평균
 , (recall + precision) / 2 as arithmetic_mean
  -- 기하 평균
 , power(recall*precision, 1.0/2) as geometrics_mean
 -- 조화 평균
 ,2.0/((1.0/recall) +(1.0/precision)) as harmonic_mean
 from
  search_evaluation_by_col
 -- 값이 0보다 큰 것만으로 한정
 where recall*precision >0
 order by path
 ;
 
-- 24-2 가로 기반 데이터의 평균을 계산하는 쿼리
select 
 path
-- 산술 평균
, avg(value) as arithmetic_mean
-- 기하평균(대수의 산술 평균)
, power(10, avg(log(value))) as geometric_mean
from
 search_evaluation_by_row
 -- 값이 0보다 큰 것만으로 한정
where value > 0
group by path
  -- 빠진 데이터가 없게 path로 한정하기
having count(*) = 2
order by path
;

-- 24-3 세로 기반 데이터의 가중 평균을 계산하는 쿼리
select 
 *
 -- 가중치가 추가된 산술 평균
 , 0.3*recall + 0.7*precision as weighted_a_mean
 -- 가중치가 추가된 기하 평균
 , power(recall,0.3) * power(precision, 0.7) as weighted_g_mean
 -- 가중치가 추가된 조화 평균
 , 1.0/((3.0/recall)+(0.7/precision)) as weighted_h_mean
 from
  search_evaluation_by_col
  -- 값이 0보다 큰 것만으로 한정하기
  where recall*precision > 0
  order by path
  ;
  
-- 24-4 가로 기반 테이블의 가중 평균을 계산하는 쿼리
with
weights as (
  -- 가중치 마스터 테이블(가중치 합계가 1.0이 되게 설정)
	        select 'recall' as index, 0.3 as weight
	union all select 'precision' as index, 0.7 as weight
)
select 
  e.path
  -- 가중치가 추가된 산술 평균
  , sum(w.weight * e.value) as weighted_a_mean
  -- 가중치가 추가된 기하 평균
  ,power(10, sum(w.weight*log(e.value))) as weighted_g_mean
  
  -- 가중치가 추가된 조화 평균
  , 1.0 / (sum(w.weight/e.value)) as weighted_g_mean
  
   -- 가중치가 조화 평균
   , 1.0/ (sum(w.weight/e.value)) as weighted_h_mean
from
 search_evaluation_by_row as e
 join
  weights as w
  on e.index = w.index
  -- 값이 0 보다 큰 것만으로 한정
  where e.value >0
  group by e.path
  -- 빠진 데이터가 없게 path로 한정하기
  having count(*) = 2
  order by e.path
  ;