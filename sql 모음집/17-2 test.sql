DROP TABLE IF EXISTS access_log;
CREATE TABLE access_log(
    session  varchar(255)
  , user_id  varchar(255)
  , action   varchar(255)
  , stamp    varchar(255)
);

INSERT INTO access_log
VALUES
    ('98900e', 'U001', 'view', '2016-01-01 18:00:00')
  , ('98900e', 'U001', 'view', '2016-01-02 20:00:00')
  , ('98900e', 'U001', 'view', '2016-01-03 22:00:00')
  , ('1cf768', 'U002', 'view', '2016-01-04 23:00:00')
  , ('1cf768', 'U002', 'view', '2016-01-05 00:30:00')
  , ('1cf768', 'U002', 'view', '2016-01-06 02:30:00')
  , ('87b575', 'U001', 'view', '2016-01-07 03:30:00')
  , ('87b575', 'U001', 'view', '2016-01-08 04:00:00')
  , ('87b575', 'U001', 'view', '2016-01-09 12:00:00')
  , ('eee2b2', 'U002', 'view', '2016-01-10 13:00:00')
  , ('eee2b2', 'U001', 'view', '2016-01-11 15:00:00')
;

-- 17-3 PostgreSQL에서의 주말과 공휴일을 정의하는 방법 예
drop table if exists mst_city_ip;
create table mst_calendar(
 year integer
	, month integer
	, day integer
	, dow varchar(10)
	, dow_num integer
	, holiday_name varchar(255)
);

-- 17-4 주말과 공휴일을 판정하는 쿼리
select 
 a.action
 , a.stamp
 , c.dow
 , c.holiday_name
   -- 주말과 공휴일 판정
   , c.dow_num in (0, 6) -- 토요일과 일요일 판정
     or c.holiday_name is not null -- 공휴일 판정하기
	 as is_day_off
	 from
	  access_log as a
	  join
	   mst_calendar as c
	   on cast(substring(a.stamp, 1, 4) as int) = c.year
	   and cast(substring(a.stamp, 6, 2) as int) = c.month
	   and cast(substring(a.stamp, 9, 2) as int) = c.day
	   ;