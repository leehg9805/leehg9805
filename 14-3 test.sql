DROP TABLE IF EXISTS access_log;
CREATE TABLE access_log(
    stamp         varchar(255)
  , short_session varchar(255)
  , long_session  varchar(255)
  , url           text
  , referrer      text
);

INSERT INTO access_log
VALUES
    ('2016-10-01 12:00:00', '0CVKaz', '1CwlSX', 'http://www.example.com/?utm_source=google&utm_medium=search'       , 'http://www.google.co.jp/xxx'      )
  , ('2016-10-01 13:00:00', '0CVKaz', '1CwlSX', 'http://www.example.com/detail?id=1'                                , ''                                 )
  , ('2016-10-01 13:00:00', '1QceiB', '3JMO2k', 'http://www.example.com/list/cd'                                    , ''                                 )
  , ('2016-10-01 14:00:00', '1QceiB', '3JMO2k', 'http://www.example.com/detail?id=1'                                , 'http://search.google.co.jp/xxx'   )
  , ('2016-10-01 15:00:00', '1hI43A', '6SN6DD', 'http://www.example.com/list/newly'                                 , ''                                 )
  , ('2016-10-01 16:00:00', '1hI43A', '6SN6DD', 'http://www.example.com/list/cd'                                    , 'http://www.example.com/list/newly')
  , ('2016-10-01 17:00:00', '2bGs3i', '1CwlSX', 'http://www.example.com/'                                           , ''                                 )
  , ('2016-10-01 18:00:00', '2is8PX', '7Dn99b', 'http://www.example.com/detail?id=2'                                , 'https://twitter.com/xxx'          )
  , ('2016-10-02 12:00:00', '2mmGwD', 'EFnoNR', 'http://www.example.com/'                                           , ''                                 )
  , ('2016-10-02 13:00:00', '2mmGwD', 'EFnoNR', 'http://www.example.com/list/cd'                                    , 'http://search.google.co.jp/xxx'   )
  , ('2016-10-02 14:00:00', '3CEHe1', 'FGkTe9', 'http://www.example.com/list/dvd'                                   , ''                                 )
  , ('2016-10-02 15:00:00', '3Gv8vO', '1CwlSX', 'http://www.example.com/detail?id=2'                                , ''                                 )
  , ('2016-10-02 16:00:00', '3cv4gm', 'KBlKgT', 'http://www.example.com/list/newly'                                 , 'http://search.yahoo.co.jp/xxx'    )
  , ('2016-10-02 17:00:00', '3cv4gm', 'KBlKgT', 'http://www.example.com/'                                           , 'https://www.facebook.com/xxx'     )
  , ('2016-10-02 18:00:00', '690mvB', 'FGkTe9', 'http://www.example.com/list/dvd?utm_source=yahoo&utm_medium=search', 'http://www.yahoo.co.jp/xxx'       )
  , ('2016-10-03 12:00:00', '6oABhM', '3JMO2k', 'http://www.example.com/detail?id=3'                                , 'http://search.yahoo.co.jp/xxx'    )
  , ('2016-10-03 13:00:00', '7jjxQX', 'KKTw9P', 'http://www.example.com/?utm_source=mynavi&utm_medium=affiliate'    , 'http://www.mynavi.jp/xxx'         )
  , ('2016-10-03 14:00:00', 'AAuoEU', '6SN6DD', 'http://www.example.com/list/dvd'                                   , 'https://www.facebook.com/xxx'     )
  , ('2016-10-03 15:00:00', 'AAuoEU', '6SN6DD', 'http://www.example.com/list/newly'                                 , ''                                 )
;

DROP TABLE IF EXISTS purchase_log;
CREATE TABLE purchase_log(
    stamp         varchar(255)
  , short_session varchar(255)
  , long_session  varchar(255)
  , purchase_id   integer
  , amount        integer
);

INSERT INTO purchase_log
VALUES
    ('2016-10-01 15:00:00', '0CVKaz', '1CwlSX', 1, 1000)
  , ('2016-10-01 16:00:00', '2is8PX', '7Dn99b', 2, 1000)
  , ('2016-10-01 20:00:00', '2is8PX', '7Dn99b', 3, 1000)
  , ('2016-10-02 14:00:00', '2is8PX', '7Dn99b', 4, 1000)
;

-- 14-5 유입원별로 방문 횟수를 집계하는 쿼리
with
access_log_with_parse_info as (
  -- 유입원 정보 추출하기
	select *
	, substring(url from 'https?://([^/]*)') as url_domain
	, substring(url from 'utm_source=([^&]*)') as url_utm_source
	, substring(url from 'utm_medium=([^&]*)') as url_utm_medium
	, substring(referrer from 'https?://([^/]*)') as referrer_domain
	
	from access_log
)
, access_log_with_via_info as (
  select *
	, row_number() over(order by stamp) as log_id
	, case
	    when url_utm_source <> '' and url_utm_medium <> ''
	     then concat(url_utm_source, '-', url_utm_medium)
	    when referrer_domain IN ('search.yahoo.co.jp', 'www.google.co.jp') then 'search'
	    when referrer_domain IN ('twitter.com', 'www.facebook.com') then 'social'
	    else 'other'
	  end as via
	from access_log_with_parse_info
	-- 레퍼러가 없는 경우와 우리 사이트 도메인의 경우는 제외
	where coalesce(referrer_domain, '') not in ('', url_domain)
)
select via, count(1) as access_count
from access_log_with_via_info
group by via
order by access_count desc;

-- 14-6 각 방문에서 구매한 비율(CVR)을 집계하는 쿼리
with
access_log_with_parse_info as (
  -- 유입원 정보 추출하기
	select *
	, substring(url from 'https?://([^/]*)') as url_domain
	, substring(url from 'utm_source=([^&]*)') as url_utm_source
	, substring(url from 'utm_medium=([^&]*)') as url_utm_medium
	, substring(referrer from 'https?://([^/]*)') as referrer_domain
	
	from access_log
)
, access_log_with_via_info as (
  select *
	, row_number() over(order by stamp) as log_id
	, case
	    when url_utm_source <> '' and url_utm_medium <> ''
	     then concat(url_utm_source, '-', url_utm_medium)
	    when referrer_domain IN ('search.yahoo.co.jp', 'www.google.co.jp') then 'search'
	    when referrer_domain IN ('twitter.com', 'www.facebook.com') then 'social'
	    else 'other'
	  end as via
	from access_log_with_parse_info
	-- 레퍼러가 없는 경우와 우리 사이트 도메인의 경우는 제외
	where coalesce(referrer_domain, '') not in ('', url_domain)
)
, access_log_with_purchase_amount as (
 select
	 a.log_id
	, a.via
	, sum(
	    case
		  when p.stamp::date between a.stamp::date and a.stamp::date+'1 day'::interval
		then amount
		end
	)  as amount
	from
	   access_log_with_via_info as a
	left outer join
	   purchase_log as p
	   on a.long_session = p.long_session
	group by a.log_id, a.via
)
    select
	   via
	   , count(1) as via_count
	   , count(amount) as conversions
	   , avg(100.0*sign(coalesce(amount,0))) as cvr
	   , sum(coalesce(amount, 0)) as amount
	   , avg(1.0*coalesce(amount, 0)) as avg_amount
	   from
	    access_log_with_purchase_amount
		group by via
		order by cvr desc
		;

