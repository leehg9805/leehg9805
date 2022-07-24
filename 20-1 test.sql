DROP TABLE IF EXISTS mst_products_20161201;
CREATE TABLE mst_products_20161201(
    product_id  varchar(255)
  , name        varchar(255)
  , price       integer
  , updated_at  varchar(255)
);

INSERT INTO mst_products_20161201
VALUES
    ('A001', 'AAA', 3000, '2016-11-03 18:00:00')
  , ('A002', 'AAB', 4000, '2016-11-03 19:00:00')
  , ('B001', 'BBB', 5000, '2016-11-03 20:00:00')
  , ('B002', 'BBD', 3000, '2016-11-03 21:00:00')
  , ('C001', 'CCA', 4000, '2016-11-04 18:00:00')
  , ('D001', 'DAA', 5000, '2016-11-04 19:00:00')
;

DROP TABLE IF EXISTS mst_products_20170101;
CREATE TABLE mst_products_20170101(
    product_id  varchar(255)
  , name        varchar(255)
  , price       integer
  , updated_at  varchar(255)
);

INSERT INTO mst_products_20170101
  VALUES
    ('A001', 'AAA', 3000, '2016-11-03 18:00:00')
  , ('A002', 'AAB', 4000, '2016-11-03 19:00:00')
  , ('B002', 'BBD', 3000, '2016-11-03 21:00:00')
  , ('C001', 'CCA', 5000, '2016-12-04 18:00:00')
  , ('D001', 'DAA', 5000, '2016-11-04 19:00:00')
  , ('D002', 'DAD', 5000, '2016-12-04 19:00:00')
;

-- 20-1 추가된 마스터 데이터를 추출하는 쿼리
select 
 new_mst.*
from
 mst_products_20170101 as new_mst
 left outer join
  mst_products_20161201 as old_mst
 on 
  new_mst.product_id = old_mst.product_id
 where
  old_mst.product_id is null
  ;
  
-- 20-2 제거된 마스터 데이터를 추출하는 쿼리
select 
 old_mst.*
from
 mst_products_20170101 as new_mst
right outer join
 mst_products_20161201 as old_mst
on 
 new_mst.product_id = old_mst.product_id
where 
 new_mst.product_id is null
 ;
 
-- 20-3 변경된 마스터 데이터를 추출하는 쿼리
select 
 new_mst.product_id
 , old_mst.name as old_name
 , old_mst.price as old_price
 , new_mst.name as new_name
 , new_mst.price as new_price
 , new_mst.updated_at
from
 mst_products_20170101 as new_mst
join 
 mst_products_20161201 as old_mst
on
 new_mst.product_id = old_mst.product_id
where 
 -- 갱신 시점이 다른 레코드만 추출하기
 new_mst.updated_at <> old_mst.updated_at
 ;
 
-- 20-4 변경된 마스터 데이터를 모두 추출하는 쿼리
select 
 coalesce(new_mst.product_id, old_mst.product_id) as product_id
 ,coalesce(new_mst.name, old_mst.name ) as name
 ,coalesce(new_mst.price, old_mst.price) as price
 ,coalesce(new_mst.updated_at, old_mst.updated_at) as updated_at
 ,case 
  when old_mst.updated_at is null then 'added'
  when new_mst.updated_at is null then 'deleted'
  when new_mst.updated_at <> old_mst.updated_at then 'updated'
 end as status
 from
  mst_products_20170101 as new_mst
 full outer join 
  mst_products_20161201 as old_mst
  on
   new_mst.product_id = old_mst.product_id
  where
   new_mst.updated_at is distinct from old_mst.updated_at
   ;