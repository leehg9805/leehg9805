DROP TABLE IF EXISTS monthly_sales;
CREATE TABLE monthly_sales(
    year_month varchar(255)
  , item       varchar(255)
  , amount     integer
);

INSERT INTO monthly_sales
VALUES
   ('2016-01', 'D001', 30000)
 , ('2016-01', 'D002', 10000)
 , ('2016-01', 'D003',  5000)
 , ('2016-01', 'D004',  3000)
 , ('2016-02', 'D001', 30000)
 , ('2016-02', 'D002', 30000)
 , ('2016-02', 'D005', 20000)
 , ('2016-02', 'D003', 10000)
 , ('2016-03', 'D002', 40000)
 , ('2016-03', 'D005', 40000)
 , ('2016-03', 'D001', 20000)
 , ('2016-03', 'D003', 16000)
 , ('2016-10', 'D005', 50000)
 , ('2016-10', 'D004', 40000)
 , ('2016-10', 'D006', 30000)
 , ('2016-10', 'D003', 30000)
 , ('2016-11', 'D006', 60000)
 , ('2016-11', 'D004', 40000)
 , ('2016-11', 'D003', 40000)
 , ('2016-11', 'D001', 40000)
 , ('2016-12', 'D006', 70000)
 , ('2016-12', 'D003', 60000)
 , ('2016-12', 'D004', 50000)
 , ('2016-12', 'D001', 40000)
;

-- 24-12 분기별 상품 매출액과 매출 합계를 집계하는 쿼리
with
item_sales_per_quarters as (
 select 
	 item
	-- 2016년 1분기의 상품 매출 모두 더하기
	, sum(
	   case when year_month in('2016-01', '2016-02', '2016-03') then amount else 0 end
	) as sales_2016_q1
	 -- 2016년 4분기의 상품 매출 모두 더하기
	, sum(
	  case when year_month in ('2016-10', '2016-11', '2016-12') then amount else 0 end
	) as sales_2016_q4
	from monthly_sales 
	group by
	 item
)
select 
item
-- 2916년 1분기의 상품 매출
, sales_2016_q1
-- 2016년 1분기의 상품 매출 합계
, sum(sales_2016_q1) over() as sum_sales_2016_q1
-- 2016년 4분기의 상품 매출
, sales_2016_q4
-- 2016년 4분기의 상품 매출 합계
, sum(sales_2016_q4) over() as sum_sales_2016_q4
from item_sales_per_quarters
;

-- 24-13 분기별 상품 매출액을 기반으로 점수를 계산하는 쿼리
with
item_sales_per_quarters as (
 select 
	 item
	-- 2016년 1분기의 상품 매출 모두 더하기
	, sum(
	   case when year_month in('2016-01', '2016-02', '2016-03') then amount else 0 end
	) as sales_2016_q1
	 -- 2016년 4분기의 상품 매출 모두 더하기
	, sum(
	  case when year_month in ('2016-10', '2016-11', '2016-12') then amount else 0 end
	) as sales_2016_q4
	from monthly_sales 
	group by
	 item
)
,item_score_per_quarters as (
  select 
	 item
	, sales_2016_q1
	, 1.0
	 * (sales_2016_q1 - min(sales_2016_q1) over())
	/nullif(max(sales_2016_q1) over() - min(sales_2016_q1) over(), 0)
	as score_2016_q1
	, sales_2016_q1
	,sales_2016_q4
	,1.0
	* (sales_2016_q4 - min(sales_2016_q4) over())
	/nullif(max(sales_2016_q4) over()-min(sales_2016_q4) over(), 0)
	 as score_2016_q4
 from item_sales_per_quarters
)
select *
from item_sales_per_quarters
;

-- 24-14 분기별 상품 점수 가중 평균으로 순위를 생성하는 쿼리
with
item_sales_per_quarters as (
 select 
	 item
	-- 2016년 1분기의 상품 매출 모두 더하기
	, sum(
	   case when year_month in('2016-01', '2016-02', '2016-03') then amount else 0 end
	) as sales_2016_q1
	 -- 2016년 4분기의 상품 매출 모두 더하기
	, sum(
	  case when year_month in ('2016-10', '2016-11', '2016-12') then amount else 0 end
	) as sales_2016_q4
	from monthly_sales 
	group by
	 item
)
,item_score_per_quarters as (
  select 
	 item
	, sales_2016_q1
	, 1.0
	 * (sales_2016_q1 - min(sales_2016_q1) over())
	/nullif(max(sales_2016_q1) over() - min(sales_2016_q1) over(), 0)
	as score_2016_q1
	, sales_2016_q1
	,sales_2016_q4
	,1.0
	* (sales_2016_q4 - min(sales_2016_q4) over())
	/nullif(max(sales_2016_q4) over()-min(sales_2016_q4) over(), 0)
	 as score_2016_q4
 from item_sales_per_quarters
)
select 
  item
  , 0.7 *score_2016_q1 + 0.3*score_2016_q4 as score
  ,row_number()
       over(order by 0.7*score_2016_q1 +0.3*score_2016_q4 desc)
	    as rank
from item_score_per_quarters
order by rank
;
