DROP TABLE IF EXISTS mst_categories;
CREATE TABLE mst_categories (
    category_id integer
  , name        varchar(255)
);

INSERT INTO mst_categories
VALUES
    (1, 'dvd' )
  , (2, 'cd'  )
  , (3, 'book')
;

DROP TABLE IF EXISTS category_sales;
CREATE TABLE category_sales (
    category_id integer
  , sales       integer
);

INSERT INTO category_sales
VALUES
    (1, 850000)
  , (2, 500000)
;

DROP TABLE IF EXISTS product_sale_ranking;
CREATE TABLE product_sale_ranking (
    category_id integer
  , rank        integer
  , product_id  varchar(255)
  , sales       integer
);

INSERT INTO product_sale_ranking
VALUES
    (1, 1, 'D001', 50000)
  , (1, 2, 'D002', 20000)
  , (1, 3, 'D003', 10000)
  , (2, 1, 'C001', 30000)
  , (2, 2, 'C002', 20000)
  , (2, 3, 'C003', 10000)
;

-- 8-2 여러 개의 테이블을 결합해서 가로로 정렬하는 쿼리
select
   m.category_id
   , m.name
   , s.sales
   , r.product_id as sale_product
from 
  mst_categories as m
  JOIN
  -- 카테고리별로 매출액 결합하기
  category_sales as s
  on m.category_id = s.category_id
  JOIN
  -- 카테고리별로 상품 결합하기
  product_sale_ranking as r
  on m.category_id = r.category_id
  ;
  
-- 8-3 마스터 테이블의 행 수를 변경하지 않고 여러 개의 테이블을 가로로 정렬하는 쿼리
select
   m.category_id
   , m.name
   , s.sales
   , r.product_id as top_sale_product
 from
    mst_categories as m
	-- left join을 사용해서 결합한 레코드를 남김
	left join 
	 -- 카테고리별 매출액 결합하기
	 category_sales as s
	 on m.category_id = s.category_id
	 -- left join을 사용해서 결합하지 못한 레코드를 남김
	 left join
	  -- 카테고리별 최고 매출 상품 하나만 추출해서 결합하기
	  product_sale_ranking as r
	  on m.category_id = r.category_id
	  and r.rank =1
	  ;
	  
-- 8-4 상관 서브쿼리 여러 개의 테이블을 가로로 정렬하는 쿼리
select 
  m.category_id
  , m.name
    -- 상관 서브쿼리를 사용해 카테고리별로 매출액 구하기
	,(select s.sales
	 from category_sales as s
	 where m.category_id = s.category_id
	 ) as sales 
	  -- 상관 서브쿼리를 사용해 카테고리별로 최고 매출 상품을
	  -- 하나 추출하기(순위로 따로 압축하지 않아도 됨)
	  , (select r.product_id
		from product_sale_ranking as r
		where m.category_id = r.category_id
		order by sales desc
		limit 1
		) as top_sale_product
		from
		mst_categories as m
		;
		 