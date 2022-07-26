DROP TABLE IF EXISTS mst_users;
CREATE TABLE mst_users(
    user_id         varchar(255)
  , sex             varchar(255)
  , birth_date      varchar(255)
  , register_date   varchar(255)
  , register_device varchar(255)
  , withdraw_date   varchar(255)
);

INSERT INTO mst_users
VALUES
    ('U001', 'M', '1977-06-17', '2016-10-01', 'pc' , NULL        )
  , ('U002', 'F', '1953-06-12', '2016-10-01', 'sp' , '2016-10-10')
  , ('U003', 'M', '1965-01-06', '2016-10-01', 'pc' , NULL        )
  , ('U004', 'F', '1954-05-21', '2016-10-01', 'pc' , NULL        )
  , ('U005', 'M', '1987-11-23', '2016-10-01', 'sp' , NULL        )
  , ('U006', 'F', '1950-01-21', '2016-10-01', 'pc' , '2016-10-10')
  , ('U007', 'F', '1950-07-18', '2016-10-01', 'app', NULL        )
  , ('U008', 'F', '2006-12-09', '2016-10-01', 'sp' , NULL        )
  , ('U009', 'M', '2004-10-23', '2016-10-01', 'pc' , NULL        )
  , ('U010', 'F', '1987-03-18', '2016-10-01', 'pc' , NULL        )
  , ('U011', 'F', '1993-10-21', '2016-10-01', 'pc' , NULL        )
  , ('U012', 'M', '1993-12-22', '2016-10-01', 'app', NULL        )
  , ('U013', 'M', '1988-02-09', '2016-10-01', 'app', NULL        )
  , ('U014', 'F', '1994-04-07', '2016-10-01', 'sp' , NULL        )
  , ('U015', 'F', '1994-03-01', '2016-10-01', 'app', NULL        )
  , ('U016', 'F', '1991-09-02', '2016-10-01', 'pc' , NULL        )
  , ('U017', 'F', '1972-05-21', '2016-10-01', 'app', NULL        )
  , ('U018', 'M', '2009-10-12', '2016-10-01', 'app', NULL        )
  , ('U019', 'M', '1957-05-18', '2016-10-01', 'pc' , NULL        )
  , ('U020', 'F', '1954-04-17', '2016-10-02', 'app', NULL        )
  , ('U021', 'M', '2002-08-14', '2016-10-02', 'sp' , NULL        )
  , ('U022', 'M', '1979-12-09', '2016-10-02', 'app', NULL        )
  , ('U023', 'M', '1992-01-12', '2016-10-02', 'sp' , NULL        )
  , ('U024', 'F', '1962-10-16', '2016-10-02', 'app', NULL        )
  , ('U025', 'F', '1958-06-26', '2016-10-02', 'app', NULL        )
  , ('U026', 'M', '1969-02-21', '2016-10-02', 'sp' , NULL        )
  , ('U027', 'F', '2001-07-10', '2016-10-02', 'pc' , NULL        )
  , ('U028', 'M', '1976-05-26', '2016-10-02', 'app', NULL        )
  , ('U029', 'M', '1964-04-06', '2016-10-02', 'pc' , NULL        )
  , ('U030', 'M', '1959-10-07', '2016-10-02', 'sp' , NULL        )

;

DROP TABLE IF EXISTS action_log;
CREATE TABLE action_log(
    session  varchar(255)
  , user_id  varchar(255)
  , action   varchar(255)
  , stamp    varchar(255)
);

INSERT INTO action_log
VALUES
    ('989004ea', 'U001', 'view'   ,'2016-10-01 18:00:00')
  , ('989004ea', 'U001', 'view'   ,'2016-10-01 18:01:00')
  , ('989004ea', 'U001', 'view'   ,'2016-10-01 18:10:00')
  , ('47db0370', 'U001', 'follow' ,'2016-10-05 19:00:00')
  , ('47db0370', 'U001', 'view'   ,'2016-10-05 19:10:00')
  , ('47db0370', 'U001', 'follow' ,'2016-10-05 20:30:00')
  , ('5asfv583', 'U001', 'follow' ,'2016-10-20 19:00:00')
  , ('5asfv583', 'U001', 'view'   ,'2016-10-20 19:10:00')
  , ('5asfv583', 'U001', 'follow' ,'2016-10-20 20:30:00')
  , ('536jdqk2', 'U001', 'view'   ,'2016-12-01 19:00:00')
  , ('1gs7jacx', 'U001', 'view'   ,'2017-01-01 19:00:00')
  , ('87b5725f', 'U002', 'follow' ,'2016-10-01 12:00:00')
  , ('87b5725f', 'U002', 'follow' ,'2016-10-01 12:01:00')
  , ('87b5725f', 'U002', 'follow' ,'2016-10-01 12:02:00')
  , ('9afaf87c', 'U002', 'view'   ,'2016-10-02 13:00:00')
  , ('9afaf87c', 'U002', 'comment','2016-10-02 15:00:00')
  , ('afsd4bag', 'U002', 'view'   ,'2016-10-10 15:00:00')
  , ('ga43q56a', 'U003', 'view'   ,'2016-10-01 12:00:00')
  , ('854jcq5m', 'U004', 'view'   ,'2016-10-01 12:00:00')
;


-- 12-26 성장지수 산출을 위해 사용자 상태를 집계하는 쿼리
WITH
unique_action_log AS (
  -- 같은 날짜 로그를 중복해 세지 않도록 중복 배제하기
	SELECT DISTINCT
	   user_id
	 , substring(stamp, 1, 10) AS action_date
	FROM
	 action_log
)
, mst_calendar AS (
  -- 집계하고 싶은 기간을 캘린더 테이블로 만들기
  -- generate_series 등으로 동적 생성도 가능
	SELECT '2016-10-01' AS dt
	UNION ALL SELECT '2016-10-02' AS dt
	UNION ALL SELECT '2016-10-03' AS dt
	UNION ALL SELECT '2016-10-04' AS dt
	UNION ALL SELECT '2016-10-05' AS dt
	UNION ALL SELECT '2016-10-06' AS dt
	UNION ALL SELECT '2016-10-07' AS dt
	UNION ALL SELECT '2016-10-08' AS dt
	UNION ALL SELECT '2016-10-09' AS dt
	UNION ALL SELECT '2016-10-10' AS dt
	UNION ALL SELECT '2016-10-11' AS dt
	UNION ALL SELECT '2016-10-12' AS dt
	UNION ALL SELECT '2016-10-13' AS dt
	UNION ALL SELECT '2016-10-14' AS dt
	UNION ALL SELECT '2016-10-15' AS dt
	UNION ALL SELECT '2016-10-16' AS dt
	UNION ALL SELECT '2016-10-17' AS dt
	UNION ALL SELECT '2016-10-18' AS dt
	UNION ALL SELECT '2016-10-19' AS dt
	UNION ALL SELECT '2016-10-20' AS dt
	UNION ALL SELECT '2016-10-21' AS dt
	UNION ALL SELECT '2016-10-22' AS dt
	UNION ALL SELECT '2016-10-23' AS dt
	UNION ALL SELECT '2016-10-24' AS dt
	UNION ALL SELECT '2016-10-25' AS dt
	UNION ALL SELECT '2016-10-26' AS dt
	UNION ALL SELECT '2016-10-27' AS dt
	UNION ALL SELECT '2016-10-28' AS dt
	UNION ALL SELECT '2016-10-29' AS dt
	UNION ALL SELECT '2016-10-30' AS dt
	UNION ALL SELECT '2016-10-31' AS dt
	UNION ALL SELECT '2016-11-01' AS dt
	UNION ALL SELECT '2016-11-02' AS dt
	UNION ALL SELECT '2016-11-03' AS dt
	UNION ALL SELECT '2016-11-04' AS dt
	
)
, target_date_with_user AS (
  -- 사용자 마스터에 캘린더 테이블의 날짜를 target_date로 추가
	SELECT
	    c.dt AS target_date
	   ,u.user_id
	   ,u.register_date
	   ,u.withdraw_date
	FROM
	   mst_users AS u
	CROSS JOIN
	 mst_calendar AS c
)
, user_status_log AS (
  SELECT
	 u.target_date
	,u.user_id
	,u.register_date
	,u.withdraw_date
	,a.action_date
	,case when u.register_date = a.action_date then 1 else 0 end as is_new
	,case when u.withdraw_date = a.action_date then 1 else 0 end as is_exit
	,case when u.target_date   = a.action_date then 1 else 0 end as is_access
	,lag(case when u.target_date = a.action_date then 1 else 0 end)
	over(
	  partition by u.user_id
		order by u.target_date
	) as was_access
	FROM
	 target_date_with_user as u
	left join
	 unique_action_log as a
	on u.user_id = a.user_id
	and u.target_date=a.action_date
	where
	u.register_date <= u.target_date
	and(
	    u.withdraw_date is null
		or u.target_date <= u.withdraw_date
		
	)
)
select
   target_date
   , user_id
   , is_new
   , is_exit
   , is_access
   , was_access
   FROM
    user_status_log
	;
	

-- 12-27 매일의 성장지수를 계산하는 쿼리
WITH
unique_action_log AS (
  -- 같은 날짜 로그를 중복해 세지 않도록 중복 배제하기
	SELECT DISTINCT
	   user_id
	 , substring(stamp, 1, 10) AS action_date
	FROM
	 action_log
)
, mst_calendar AS (
  -- 집계하고 싶은 기간을 캘린더 테이블로 만들기
  -- generate_series 등으로 동적 생성도 가능
	SELECT '2016-10-01' AS dt
	UNION ALL SELECT '2016-10-02' AS dt
	UNION ALL SELECT '2016-10-03' AS dt
	UNION ALL SELECT '2016-10-04' AS dt
	UNION ALL SELECT '2016-10-05' AS dt
	UNION ALL SELECT '2016-10-06' AS dt
	UNION ALL SELECT '2016-10-07' AS dt
	UNION ALL SELECT '2016-10-08' AS dt
	UNION ALL SELECT '2016-10-09' AS dt
	UNION ALL SELECT '2016-10-10' AS dt
	UNION ALL SELECT '2016-10-11' AS dt
	UNION ALL SELECT '2016-10-12' AS dt
	UNION ALL SELECT '2016-10-13' AS dt
	UNION ALL SELECT '2016-10-14' AS dt
	UNION ALL SELECT '2016-10-15' AS dt
	UNION ALL SELECT '2016-10-16' AS dt
	UNION ALL SELECT '2016-10-17' AS dt
	UNION ALL SELECT '2016-10-18' AS dt
	UNION ALL SELECT '2016-10-19' AS dt
	UNION ALL SELECT '2016-10-20' AS dt
	UNION ALL SELECT '2016-10-21' AS dt
	UNION ALL SELECT '2016-10-22' AS dt
	UNION ALL SELECT '2016-10-23' AS dt
	UNION ALL SELECT '2016-10-24' AS dt
	UNION ALL SELECT '2016-10-25' AS dt
	UNION ALL SELECT '2016-10-26' AS dt
	UNION ALL SELECT '2016-10-27' AS dt
	UNION ALL SELECT '2016-10-28' AS dt
	UNION ALL SELECT '2016-10-29' AS dt
	UNION ALL SELECT '2016-10-30' AS dt
	UNION ALL SELECT '2016-10-31' AS dt
	UNION ALL SELECT '2016-11-01' AS dt
	UNION ALL SELECT '2016-11-02' AS dt
	UNION ALL SELECT '2016-11-03' AS dt
	UNION ALL SELECT '2016-11-04' AS dt
	
)
, target_date_with_user AS (
  -- 사용자 마스터에 캘린더 테이블의 날짜를 target_date로 추가
	SELECT
	    c.dt AS target_date
	   ,u.user_id
	   ,u.register_date
	   ,u.withdraw_date
	FROM
	   mst_users AS u
	CROSS JOIN
	 mst_calendar AS c
)
, user_status_log AS (
  SELECT
	 u.target_date
	,u.user_id
	,u.register_date
	,u.withdraw_date
	,a.action_date
	,case when u.register_date = a.action_date then 1 else 0 end as is_new
	,case when u.withdraw_date = a.action_date then 1 else 0 end as is_exit
	,case when u.target_date   = a.action_date then 1 else 0 end as is_access
	,lag(case when u.target_date = a.action_date then 1 else 0 end)
	over(
	  partition by u.user_id
		order by u.target_date
	) as was_access
	FROM
	 target_date_with_user as u
	left join
	 unique_action_log as a
	on u.user_id = a.user_id
	and u.target_date=a.action_date
	where
	u.register_date <= u.target_date
	and(
	    u.withdraw_date is null
		or u.target_date <= u.withdraw_date
		
	)
)
, user_growth_index AS (
  SELECT
	*
	, case
	 when is_new+is_exit=1then
	 case
	 when is_new = 1 then 'signup'
	 when is_exit = 1 then 'exit'
	end
	when is_new+is_exit = 0 then
	 case
	 when was_access = 0 and is_access = 1 then 'reactivation'
	 when was_access = 1 and is_access = 0 then 'deactivation'
	end
	end as growth_index
	from
	 user_status_log
)
SELECT
  target_date
  , SUM(CASE growth_index when 'signup' then 1 else 0 end) as signup
  , SUM(CASE growth_index when 'reactivation' then 1 else 0 end) as reactivation
  , SUM(CASE growth_index when 'deactivation' then -1 else 0 end) as deactivation
  , SUM(CASE growth_index when 'exit' then 1 else 0 end) as exit
  
  , sum(
       case growth_index
	     when 'signup' then 1
	     when 'reactivation' then 1
	     when 'deactivation' then -1
	     when 'exit'         then -1
	     else 0
	  end
	  ) as growth_index
	  FROM
	   user_growth_index
	  group by
	   target_date
	   order by
	    target_date
		;