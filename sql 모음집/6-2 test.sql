DROP TABLE IF EXISTS quarterly_sales;
CREATE TABLE quarterly_sales (
    year integer
  , q1   integer
  , q2   integer
  , q3   integer
  , q4   integer
);

INSERT INTO quarterly_sales
VALUES
    (2015, 82000, 83000, 78000, 83000)
  , (2016, 85000, 85000, 80000, 81000)
  , (2017, 92000, 81000, NULL , NULL )
;
-- q1, q2 컬럼을 비교하는 쿼리
select
   year
   ,q1
   ,q2
   ,case 
   when q1<q2 then '+'
   when q1=q2 then ' '
   else '-'
   end as judge_q1_q2
   ,q2-q1 as diff_q2_q1
   ,sign(q1-q2) as sign_q2_q1
from
  quarterly_sales
order by
  year
;

-- 연간 최대/최소 4분기 매출을 찾는 쿼리
select 
    year
	, greatest(q1,q2,q3,q4) as greatest_sales
	, least(q1,q2,q3,q4)  as least_sales
from 
    quarterly_sales
order by
  year
  ;

-- 단순한 연산으로 평균 4분기 매출을 구하는 쿼리
select
   year
   , (q1+q2+q3+q4)/4 as average
from
  quarterly_sales
order by
 year
 ;

-- coalesce를 사용해 null을 0으로 변환하고 평균값을 구하는 쿼리
select 
   year
   , (coalesce(q1,0) + coalesce(q2,0) + coalesce(q3,0) + coalesce(q4,0))/4
   as average
from 
   quarterly_sales
order by
  year
;
  
--null이 아닌 칼럼만을 사용해서 평균값을 구하는 쿼리  
select 
    year
	,(coalesce(q1,0)+coalesce(q2,0)+coalesce(q3,0)+coalesce(q4,0))
	/ (sign(coalesce(q1,0))+sign(coalesce(q2,0))
	 + sign(coalesce(q3,0))+sign(coalesce(q4,0)))
	 as average
	 from
	 quarterly_sales
	 order by
	  year
	  ;
 
