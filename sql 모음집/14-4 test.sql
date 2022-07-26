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

-- 14-7 요일/시간대별 방문자 수를 집계하는 쿼리
with
access_log_with_dow as (
  select
	 stamp
	-- 일요일(0) 부터 토요일(6)까지의 요일 번호 추출
	,date_part('dow', stamp::timestamp) as dow
	
	-- 00:00:00 부터의 경과 시간을 초 단위로 계산
	, cast(substring(stamp, 12, 2) as int) * 60 *60
	+ cast(substring(stamp, 15, 2) as int) * 60
	+ cast(substring(stamp, 18, 2) as int)
	as whole_seconds
	
	-- 시간 간격 정하기
	-- 현재 예제에서는 30분(1800초)으로 지정했음
	, 30*60 as interval_seconds
	from access_log
)
, access_log_with_floor_seconds as(
  select
	 stamp
	, dow
	-- 00:00:00 부터의 경과 시간을 interval_seconds로 나누기
	, cast((floor(whole_seconds/interval_seconds)* interval_seconds) as int)
	  as floor_seconds
	from access_log_with_dow
)
, access_log_with_index as (
  select 
	 stamp
	, dow
	-- 초를 다시 타임스탬프 형식으로 변환
	, lpad(floor(floor_seconds / (60*60)):: text , 2,'0') || ':'
	      || lpad(floor(floor_seconds % (60*60) / 60):: text, 2,'0')||':'
	      || lpad(floor(floor_seconds%60)::text , 2,'0')
	as index_time
	from access_log_with_floor_seconds
)
select
  index_time
  , count(case dow when 0 then 1 end) as sun
  , count(case dow when 1 then 1 end) as mon
  , count(case dow when 2 then 1 end) as tue
  , count(case dow when 3 then 1 end) as wed
  , count(case dow when 4 then 1 end) as thu
  , count(case dow when 5 then 1 end) as fri
  , count(case dow when 6 then 1 end) as sat
  from 
    access_log_with_index
  group by 
   index_time
  order by
   index_time
   ;

