DROP TABLE IF EXISTS search_result;
CREATE TABLE search_result(
    keyword varchar(255)
  , rank    integer
  , item    varchar(255)
);

INSERT INTO search_result
  VALUES
    ('sql'     ,  1, 'book001')
  , ('sql'     ,  2, 'book005')
  , ('sql'     ,  3, 'book012')
  , ('sql'     ,  4, 'book004')
  , ('sql'     ,  5, 'book003')
  , ('sql'     ,  6, 'book010')
  , ('sql'     ,  7, 'book024')
  , ('sql'     ,  8, 'book025')
  , ('sql'     ,  9, 'book050')
  , ('sql'     , 10, 'book100')
  , ('postgres',  1, 'book002')
  , ('postgres',  2, 'book004')
  , ('postgres',  3, 'book012')
  , ('postgres',  4, 'book008')
  , ('postgres',  5, 'book003')
  , ('postgres',  6, 'book010')
  , ('postgres',  7, 'book035')
  , ('postgres',  8, 'book040')
  , ('postgres',  9, 'book077')
  , ('postgres', 10, 'book100')
  , ('hive'    ,  1, 'book200')
;

DROP TABLE IF EXISTS correct_result;
CREATE TABLE correct_result(
    keyword  varchar(255)
  , item  varchar(255)
);

INSERT INTO correct_result
VALUES
    ('sql'     , 'book003')
  , ('sql'     , 'book005')
  , ('sql'     , 'book008')
  , ('sql'     , 'book010')
  , ('sql'     , 'book025')
  , ('sql'     , 'book100')
  , ('postgres', 'book008')
  , ('postgres', 'book010')
  , ('postgres', 'book030')
  , ('postgres', 'book055')
  , ('postgres', 'book066')
  , ('postgres', 'book100')
  , ('hive'    , 'book200')
  , ('redshift', 'book300')
;


-- 21-20 정답 아이템별로 적합률 추출
with
search_result_with_correct_items as (
select 
	 coalesce(r.keyword, c.keyword) as keyword
	, r.rank
	, coalesce(r.item, c.item) as item
	, case when c.item is not null then 1 else 0 end as correct
	from
	 search_result as r
	full outer join
	 correct_result as c
	 on r.keyword = c.keyword
	 and r.item = c.item
)
, search_result_with_precision as (
  select 
	*
	-- 검색 결과의 상위에서 정답 데이터에 포함되는 아이템 수의 누계 구하기
	, sum(correct)
	    -- rank가 null이라면 정렬 순서의 마지막에 위치하므로 
	    -- 편의상 굉장히 큰 값으로 변환해서 넣기
	 over(partition by keyword order by coalesce(rank,100000) asc
		  rows between unbounded preceding and current row) as cum_correct
	, case
	  when rank is null then 0.0
	  else 
	 100.0
	 *sum(correct)
	  over(partition by keyword order by coalesce(rank,100000) asc
		  rows between unbounded preceding and current row)
	-- 재현율과 다르게 분모에 검색 결과 순위까지의 누계 아이템 수 지정
	/count(1)
	 over(partition by keyword order by coalesce(rank,100000)asc
		  rows between unbounded preceding and current row)
		 end as precision
		 from
		  search_result_with_correct_items
		 
)
select 
 keyword
 , rank
 , precision
 from
  search_result_with_precision
 where
  correct = 1
  ;
 
-- 21-21 검색 키워드별로 정확률 평균 계산 쿼리
with
search_result_with_correct_items as (
select 
	 coalesce(r.keyword, c.keyword) as keyword
	, r.rank
	, coalesce(r.item, c.item) as item
	, case when c.item is not null then 1 else 0 end as correct
	from
	 search_result as r
	full outer join
	 correct_result as c
	 on r.keyword = c.keyword
	 and r.item = c.item
)
, search_result_with_precision as (
  select 
	*
	-- 검색 결과의 상위에서 정답 데이터에 포함되는 아이템 수의 누계 구하기
	, sum(correct)
	    -- rank가 null이라면 정렬 순서의 마지막에 위치하므로 
	    -- 편의상 굉장히 큰 값으로 변환해서 넣기
	 over(partition by keyword order by coalesce(rank,100000) asc
		  rows between unbounded preceding and current row) as cum_correct
	, case
	  when rank is null then 0.0
	  else 
	 100.0
	 *sum(correct)
	  over(partition by keyword order by coalesce(rank,100000) asc
		  rows between unbounded preceding and current row)
	-- 재현율과 다르게 분모에 검색 결과 순위까지의 누계 아이템 수 지정
	/count(1)
	 over(partition by keyword order by coalesce(rank,100000)asc
		  rows between unbounded preceding and current row)
		 end as precision
		 from
		  search_result_with_correct_items
		 
)
, average_precision_for_keywords as (
  select 
	 keyword
	, avg(precision) as average_precision
	from
	 search_result_with_precision
	where
	 correct = 1
    group by
	 keyword
)
select *
from
 average_precision_for_keywords
 ;
 
-- 21-22 검색 엔진의 map을 계산하는 쿼리
with
search_result_with_correct_items as (
select 
	 coalesce(r.keyword, c.keyword) as keyword
	, r.rank
	, coalesce(r.item, c.item) as item
	, case when c.item is not null then 1 else 0 end as correct
	from
	 search_result as r
	full outer join
	 correct_result as c
	 on r.keyword = c.keyword
	 and r.item = c.item
)
, search_result_with_precision as (
  select 
	*
	-- 검색 결과의 상위에서 정답 데이터에 포함되는 아이템 수의 누계 구하기
	, sum(correct)
	    -- rank가 null이라면 정렬 순서의 마지막에 위치하므로 
	    -- 편의상 굉장히 큰 값으로 변환해서 넣기
	 over(partition by keyword order by coalesce(rank,100000) asc
		  rows between unbounded preceding and current row) as cum_correct
	, case
	  when rank is null then 0.0
	  else 
	 100.0
	 *sum(correct)
	  over(partition by keyword order by coalesce(rank,100000) asc
		  rows between unbounded preceding and current row)
	-- 재현율과 다르게 분모에 검색 결과 순위까지의 누계 아이템 수 지정
	/count(1)
	 over(partition by keyword order by coalesce(rank,100000)asc
		  rows between unbounded preceding and current row)
		 end as precision
		 from
		  search_result_with_correct_items
		 
)
, average_precision_for_keywords as (
  select 
	 keyword
	, avg(precision) as average_precision
	from
	 search_result_with_precision
	where
	 correct = 1
    group by
	 keyword
)
select 
 avg(average_precision) as mean_average_precision
from
 average_precision_for_keywords
 ;