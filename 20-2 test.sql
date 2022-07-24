DROP TABLE IF EXISTS access_log;
CREATE TABLE access_log(
    stamp          varchar(255)
  , short_session  varchar(255)
  , long_session   varchar(255)
  , path           varchar(255)
);

INSERT INTO access_log
VALUES
    ('2016-10-01 12:00:00', '0CVKaz', '1CwlSX', '/detail')
  , ('2016-10-01 13:00:00', '0CVKaz', '1CwlSX', '/detail')
  , ('2016-10-01 13:00:00', '1QceiB', '3JMO2k', '/search')
  , ('2016-10-01 14:00:00', '1QceiB', '3JMO2k', '/detail')
  , ('2016-10-01 15:00:00', '1hI43A', '6SN6DD', '/search')
  , ('2016-10-01 16:00:00', '1hI43A', '6SN6DD', '/detail')
  , ('2016-10-01 17:00:00', '2bGs3i', '1CwlSX', '/top'   )
  , ('2016-10-01 18:00:00', '2is8PX', '7Dn99b', '/search')
  , ('2016-10-02 12:00:00', '2mmGwD', 'EFnoNR', '/top'   )
  , ('2016-10-02 13:00:00', '2mmGwD', 'EFnoNR', '/detail')
  , ('2016-10-02 14:00:00', '3CEHe1', 'FGkTe9', '/search')
  , ('2016-10-02 15:00:00', '3Gv8vO', '1CwlSX', '/detail')
  , ('2016-10-02 16:00:00', '3cv4gm', 'KBlKgT', '/top'   )
  , ('2016-10-02 17:00:00', '3cv4gm', 'KBlKgT', '/search')
  , ('2016-10-02 18:00:00', '690mvB', 'FGkTe9', '/top'   )
  , ('2016-10-03 12:00:00', '6oABhM', '3JMO2k', '/detail')
  , ('2016-10-03 13:00:00', '7jjxQX', 'KKTw9P', '/top'   )
  , ('2016-10-03 14:00:00', 'AAuoEU', '6SN6DD', '/top'   )
  , ('2016-10-03 15:00:00', 'AAuoEU', '6SN6DD', '/search')
;

-- 20-5 3개의 지표를 기반으로 순위를 작성하는 쿼리
with
path_stat as (
 select 
	 path
	, count(distinct long_session) as access_users
	, count(distinct short_session) as access_count
	, count(*) as page_view
	from
	 access_log
	group by
	 path
)
, path_ranking as (
 select 'access_user' as type, path, rank() over(order by access_users desc) as rank
 from path_stat
union all
 select 'access_count' as type, path, rank() over(order by access_count desc) as rank
 from path_stat
union all
 select 'page_view' as type, path, rank() over(order by page_view desc) as rank
 from path_stat
)
select *
from
 path_ranking
order by
 type, rank
 ;
 
-- 20-6 경로들의 순위 차이를 계산하는 쿼리
with
path_stat as (
 select 
	 path
	, count(distinct long_session) as access_users
	, count(distinct short_session) as access_count
	, count(*) as page_view
	from
	 access_log
	group by
	 path
)
, path_ranking as (
 select 'access_user' as type, path, rank() over(order by access_users desc) as rank
 from path_stat
union all
 select 'access_count' as type, path, rank() over(order by access_count desc) as rank
 from path_stat
union all
 select 'page_view' as type, path, rank() over(order by page_view desc) as rank
 from path_stat
)
, pair_ranking as (
 select 
	r1.path
	,r1.type as type1
	,r1.rank as rank1
	,r2.type as type2
	,r2.rank as rank2
	 -- 순위 차이 계산하기
	,power(r1.rank-r2.rank, 2) as diff
	from
	 path_ranking as r1
	join
	 path_ranking as r2
	 on r1.path = r2.path
	
)
select 
 *
 from
  pair_ranking
 order by
  type1, type2, rank1
  ;
  
-- 20-7 스피어만 상관계수로 순위의 유사도를 계산하는 쿼리
with
path_stat as (
 select 
	 path
	, count(distinct long_session) as access_users
	, count(distinct short_session) as access_count
	, count(*) as page_view
	from
	 access_log
	group by
	 path
)
, path_ranking as (
 select 'access_user' as type, path, rank() over(order by access_users desc) as rank
 from path_stat
union all
 select 'access_count' as type, path, rank() over(order by access_count desc) as rank
 from path_stat
union all
 select 'page_view' as type, path, rank() over(order by page_view desc) as rank
 from path_stat
)
, pair_ranking as (
 select 
	r1.path
	,r1.type as type1
	,r1.rank as rank1
	,r2.type as type2
	,r2.rank as rank2
	 -- 순위 차이 계산하기
	,power(r1.rank-r2.rank, 2) as diff
	from
	 path_ranking as r1
	join
	 path_ranking as r2
	 on r1.path = r2.path
	
)
select
 type1
 ,type2
 ,1-(6.0*sum(diff)/(power(count(1),3)-count(1))) as spearman
 from
  pair_ranking
 group by
  type1, type2
 order by
  type1, spearman desc
  ;
