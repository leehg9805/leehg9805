DROP TABLE IF EXISTS mst_categories;
CREATE TABLE mst_categories(
    id     integer
  , name   varchar(255)
  , stamp  varchar(255)
);

INSERT INTO mst_categories
VALUES
    (1, 'ladys_fashion', '2016-01-01 10:00:00')
  , (2, 'mens_fashion' , '2016-01-01 10:00:00')
  , (3, 'book'         , '2016-01-01 10:00:00')
  , (4, 'game'         , '2016-01-01 10:00:00')
  , (5, 'dvd'          , '2016-01-01 10:00:00')
  , (6, 'food'         , '2016-01-01 10:00:00')
  , (7, 'supplement'   , '2016-01-01 10:00:00')
  , (6, 'cooking'      , '2016-02-01 10:00:00')
;

-- 19-1 키의 중복을 확인하는 쿼리
select 
   count(1) as total_num
   , count(distinct id) as key_num
   from 
    mst_categories
	;
	
-- 19-2 키가 중복되는 레코드의 값 확인하기
select 
  id
  , count(*) as record_num
  
  , string_agg(name, ',') as name_list
  , string_agg(stamp, ',') as stamp_list
  
  from
   mst_categories
  group by id
  having count(*) > 1 -- 중복된 ID 확인하기
  ;
  
-- 19-3 윈도 함수를 사용해서 중복된 레코드를 압축하는 쿼리
with
mst_categories_with_key_num as (
 select 
	 *
	-- ID 중복 세기
	, count(1) over(partition by id) as key_num
 from
	 mst_categories
)
select 
*
from
 mst_categories_with_key_num
where 
 key_num > 1 -- ID가 중복되는 경우 확인하기
 ;

