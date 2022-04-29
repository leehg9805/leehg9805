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

DROP TABLE IF EXISTS purchase_log;
CREATE TABLE purchase_log (
    purchase_id integer
  , product_ids varchar(255)
);

INSERT INTO purchase_log
VALUES
    (100001, 'A001,A002,A003')
  , (100002, 'D001,D002')
  , (100003, 'A001')
;


-- 일련 번호를 가진 피벗 테이블을 사용해 행으로 변환하는 쿼리
select
    q.year
  -- q1에서 q4까지의 레이블 이름 출력하기
  , case
       when p.idx = 1 then 'q1'
	   when p.idx = 2 then 'q2'
	   when p.idx = 3 then 'q3'
	   when p.idx = 4 then 'q4'
	  end as quarter
	  -- q1~q4까지의 매출 출력하기
	  ,case
	     when p.idx = 1 then q.q1
		 when p.idx = 2 then q.q2
		 when p.idx = 3 then q.q3
		 when p.idx = 4 then q.q4
		end as sales
	from  
	   quarterly_sales as q
	 cross join
	    -- 행으로 전개하고 싶은 열의 수만큼 순번 테이블 만들기
	 (          select 1 as idx
	  union all select 2 as idx
	  union all select 3 as idx
	  union all select 4 as idx
	 ) as p
	 ;
	 
-- 테이블 함수를 사용해 배열을 행으로 전개하는 쿼리
select unnest(array['A001','A002','A003']) as product_id;

-- 테이블 함수를 사용해 쉼표로 구분된 문자열 데이터를 행으로 전개하는 쿼리
select 
  purchase_id
  , product_id
from
  purchase_log as p
  -- string_to_array 함수로 문자열을 배열로 변환하고, unnest 함수로 테이블로 변환
  cross join unnest(string_to_array(product_ids, ',')) as product_id;
  
-- PostgreSQl
select 
   purchase_id
   -- 쉼표로 구분된 문자열을 한 번에 행으로 전개하기
   , regexp_split_to_table(product_ids, ',') as product_id
 from purchase_log;
 
-- 일련 번호를 가진 피벗 테이블을 만드는 쿼리
select * 
from(
            select 1 as idx
union all select 2 as idx
union all select 3 as idz
) as pivot
;

-- split_part 함수의 사용 예
select
   split_part('A001,A002,A003', ',', 1) as part_1
   ,split_part('A001,A002,A003', ',', 2) as part_2
   ,split_part('A001,A002,A003', ',', 3) as part_3
   ;
   
-- 문자 수의 차이를 사용해 상품 수를 계산하는 쿼리
select 
   purchase_id
   , product_ids
   -- 상품 ID 문자열을 기반으로 쉼표를 제거하고,
   -- 문자 수의 차이를 계산해서 상품 수 구하기
   , 1+char_length(product_ids)
        - char_length(replace(product_ids,',',''))
	as product_num
 from
   purchase_log
   ;
   
-- 피벗 테이블을 사용해 문자열을 행으로 전개하는 쿼리
select
 l.purchase_id
 ,l.product_ids
  -- 상품 수만큼 순번 붙익
  ,p.idx
  -- 문자열을 쉼표로 구분해서 분할하고, idx번째 요소 추출하기
  ,split_part(l.product_ids,',',p.idx) as product_id
from 
   purchase_log as l
   join
   (select 1 as idx
   union all select 2 as idx
   union all select 3 as idx
   ) as p
   -- 피벗 테이블의 id가 상품 수 이하의 경우 결합하기
   on p.idx<=
   (1+ char_length(l.product_ids)
     - char_length(replace(l.product_ids,',','')))
	 ;
  

  