DROP TABLE IF EXISTS product_sales;
CREATE TABLE product_sales (
    category_name varchar(255)
  , product_id    varchar(255)
  , sales         integer
);

INSERT INTO product_sales
VALUES
    ('dvd' , 'D001', 50000)
  , ('dvd' , 'D002', 20000)
  , ('dvd' , 'D003', 10000)
  , ('cd'  , 'C001', 30000)
  , ('cd'  , 'C002', 20000)
  , ('cd'  , 'C003', 10000)
  , ('book', 'B001', 20000)
  , ('book', 'B002', 15000)
  , ('book', 'B003', 10000)
  , ('book', 'B004',  5000)
;

-- 8-6 카테고리별 순위를 추가한 테이블에 이름 붙이기
with
product_sale_ranking as (
 select
  category_name
, product_id
, sales
, row_number() over(partition by category_name order by sales desc) as rank
 from
product_sales
)
select *
from product_sale_ranking
;

-- 8-7 카테고리들의 순위에서 유니크한 순위 목록을 계산하는 쿼리
with
product_sale_ranking as(
select
 category_name
,product_id
,sales
,row_number() over(partition by category_name order by sales desc) as rank
from
  product_sales
)
, mst_rank as(
select distinct rank
from product_sale_ranking
)
select *
from mst_rank
order by rank asc
;

-- 8-8 카테고리들의 순위를 횡단적으로 출력하는 쿼리
with
product_sale_ranking as (
 select
    category_name
    , product_id
, sales
,row_number() over(partition by category_name order by sales desc) as rank
from product_sales
)
, mst_rank as(
  select distinct rank
  from product_sale_ranking
)
 select
   m.rank
   ,r1.product_id as dvd
   ,r1.sales     as dvd_sales
   ,r2.product_id as cd
   ,r2.sales      as cd_sales
   ,r3.product_id as book
   ,r3.sales      as book_sales
 from
   mst_rank as m
  left join
    product_sale_ranking as r1
	on m.rank = r1.rank
	and r1.category_name = 'dvd'
   left join
   product_sale_ranking as r2
   on m.rank = r2.rank
   and r2.category_name = 'cd'
   left join
   product_sale_ranking as r3
   on m.rank = r3.rank
   and r3.category_name = 'book'
  order by m.rank
  ;