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


-- 14-2 url별로 집계하는 쿼리
select
   url
  , count(distinct short_session) as access_count
  , count(distinct long_session) as access_users
  , count(*) as page_view
  from
   access_log
  group by
   url
   ;

-- 14-3 경로별로 집계하는 쿼리
with
access_log_with_path as (
   select *
	, substring(url from '//[^/]+([^?#]+)') as url_path
	from access_log
)
select
   url_path
   , count(distinct short_session) as access_count
   , count(distinct long_session) as access_users
   , count(*) as page_view
   from
    access_log_with_path
   group by
     url_path
	 ;

-- 14-4 url에 의미를 부여해서 집계하는 쿼리
with
access_log_with_path as (
   select *
	, substring(url from '//[^/]+([^?#]+)') as url_path
	from access_log
)
, access_log_with_split_path as(
  -- 경로의 첫 번째 요소와 두 번째 요소 추출하기
	select *
	, split_part(url_path,'/',2) as path1
	, split_part(url_path,'/',3) as path2
	from access_log_with_path

)
, access_log_with_page_name as (
  -- 경로를 슬래시로 분할하고, 조건에 따라 페이지 이름 붙이기
	select *
	   , case
	      when path1 = 'list' then
	       case
	         when path2 = 'newly' then 'newly_list'
	         else 'category_list'
	        end
	      -- 이외의 경우는 경로를 그대로 사용하기
	        else url_path
	      end as page_name
	from access_log_with_split_path
)
select
   page_name
   ,count(distinct short_session) as access_count
   ,count(distinct long_session) as access_users
   ,count(*) as page_view
   from access_log_with_page_name
   group by page_name
   order by page_name
   ;


