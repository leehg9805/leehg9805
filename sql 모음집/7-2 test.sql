DROP TABLE IF EXISTS popular_products;
CREATE TABLE popular_products (
    product_id varchar(255)
  , category   varchar(255)
  , score      numeric
);

INSERT INTO popular_products
VALUES
    ('A001', 'action', 94)
  , ('A002', 'action', 81)
  , ('A003', 'action', 78)
  , ('A004', 'action', 64)
  , ('D001', 'drama' , 90)
  , ('D002', 'drama' , 82)
  , ('D003', 'drama' , 78)
  , ('D004', 'drama' , 58)
;

-- 윈도 함수의 order by 구문을 사용해 테이블 내부의 순서를 다루는 쿼리
select 
   product_id
   , score
   
   -- 점수 순서로 유일한 순위를 붙임
   , row_number()     over(order by score desc) as row
   -- 같은 순위를 허용해서 순위를 붙임
   , rank()           over(order by score desc) as rank
   -- 같은 순위가 있을 때 같은 순위 다음에 있는 순위를 건너 뛰고 순위를 붙임
   , dense_rank()     over(order by score desc) as dense_rank
   
   
   -- 현재 행보다 앞에 있는 행의 값 추출하기
   , lag(product_id)  over(order by score desc) as lag1
   , lag(product_id, 2) over(order by score desc) as lag2
   
   -- 현재 행보다 뒤에 있는 행의 값 추출하기
   ,lead(product_id)   over(order by score desc) as lead1
   ,lead(product_id,2)  over(order by score desc) as lead2
from popular_products
order by row
;

-- order by 구문과 집약 함수를 조합해서 계산하는 쿼리
select 
    product_id
	, score
	
	-- 점수 순서로 유일한 순위를 붙임
	, row_number() over(order by score desc) as row
	
	-- 순위 상위부터의 누계 점수 계산하기
	, sum(score)
	     over(order by score desc
			 rows between unbounded preceding and current row)
	  as cum_score
	  
	  -- 현재 행과 앞 뒤의 행이 가진 값을 기반으로 평균 점수 계산하기
	  , avg(score)
	       over(order by score desc
			    rows between 1 preceding and 1 following)
		as local_avg
		
	  -- 순위가 높은 상품 ID 추출하기
	  , first_value(product_id)
	      over(order by score desc
		    rows between unbounded preceding and unbounded following)
		as first_value
		
	 -- 순위가 낮은 상품 ID 추출하기
	 , last_value(product_id)
	     over(order by score desc
		      rows between unbounded preceding and unbounded following)
		as last_value
	 from popular_products
	 order by row
	 ;
	 
-- 윈도우 프레임 지정별 상품 ID를 집약하는 쿼리
select 
    product_id
	
	-- 점수 순서로 유일한 순위를 붙임
	, row_number() over(order by score desc) as row
	
	-- 가장 앞 순위부터 가장 뒷 순위까지 범위를 대상으로 상품 id 집약하기
	, array_agg(product_id)
	 over(order by score desc
		   rows between unbounded preceding and unbounded following)
	 as whole_agg
	 
	 -- 가장 앞 순위부터 현재까지의 범위를 대상으로 상품 ID 집약하기
	 , array_agg(product_id)
	 --, collect_list(product_id)
	    over(order by score desc
			rows between unbounded preceding and current row)
		as cum_agg
		
	 -- 순위 하나 앞과 하나 뒤까지의 범위를 대상으로 상품 id 집약하기
	 , array_agg(product_id)
	 --, collect_list(product_id)
	   over(order by score desc
		   rows between 1 preceding and 1 following)
		as local_agg
 from popular_products
 where category = 'action'
 order by row
 ;
 
 -- 윈도 함수를 사용해 카테고리들의 순위를 계산하는 쿼리
 select 
  category
  , product_id
  , score
    -- 카테ㅔ고리별로 점수 순서로 정렬하고 유일한 순위를 붙임
 , row_number()
     over(partition by category order by score desc)
	 as row
	 
	 -- 카테고리별로 같은 순위를 허가하고 순위 붙임
	 , rank()
	    over(partition by category order by score desc)
		as rank
		
		-- 카테고리별로 같은 순위가 있을 때
		-- 같은 순위 다음에 있는 순위를 건너 뛰고 순위를 붙임
		, dense_rank()
		    over(partition by category order by score desc)
			as dense_rank
		from popular_products
		order by category, row
		;

--카테고리들의 순위 상위 2개까지의 상품을 추출하는 쿼리
select *
  from
  -- 서브 쿼리 내부에서 순위 계산하기
  (select 
      category
  ,product_id
  ,score
     -- 카테고리별로 점수 순서로 유일한 순위를 붙임
   , row_number() 
       over(partition by category order by score desc)
      as rank
     from popular_products
     ) as popular_products_with_rank
	 -- 외부 쿼리에서 순위 활용해 압축하기
	 where rank <= 2
	 order by category, rank
	 ;
	 
-- 카테고리별 순위 최상위 상품을 추출하는 쿼리
select distinct
    category
	-- 카테고리별로 순위 최상위 상품 ID 추출하기
	, first_value(product_id)
	   over(partition by category order by score desc
		    rows between unbounded preceding and unbounded following)
		as product_id
	from popular_products
	;
