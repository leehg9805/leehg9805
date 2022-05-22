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
  , ('87b5725f', 'U002', 'follow' ,'2016-10-01 12:00:00')
  , ('87b5725f', 'U002', 'follow' ,'2016-10-01 12:01:00')
  , ('87b5725f', 'U002', 'follow' ,'2016-10-01 12:02:00')
  , ('9afaf87c', 'U002', 'view'   ,'2016-10-02 13:00:00')
  , ('9afaf87c', 'U002', 'comment','2016-10-02 15:00:00')
  , ('afsd4bag', 'U002', 'view'   ,'2016-10-25 15:00:00')
  , ('675bhjba', 'U002', 'view'   ,'2016-10-30 15:00:00')
  , ('fseg652d', 'U002', 'view'   ,'2016-11-01 15:00:00')
;

-- 12-21 12개월 후까지의 월을 도출하기 위한 보조 테이블을 만드는 쿼리
WITH
mst_intervals(interval_month) AS (
  -- 12개월 동안의 순번 만들기(generate_series 등으로 대체 가능)
  VALUES (1),(2),(3),(4),(5),(6)
	     , (7),(8),(9),(10),(11),(12)
)
SELECT *
FROM mst_intervals
;

-- 12-22 등록 월에서 12개월 후까지의 잔존율을 집계하는 쿼리
WITH
mst_intervals(interval_month) AS (
  -- 12개월 동안의 순번 만들기(generate_series 등으로 대체 가능)
  VALUES (1),(2),(3),(4),(5),(6)
	     , (7),(8),(9),(10),(11),(12)
)
, mst_users_with_index_month AS (
  -- 사용자 마스터에 등록 월부터 12개월 후까지의 월을 추가
	SELECT
	u.user_id
	, u.register_date
	-- n개월 후의 날짜, 등록일, 등록 월 n개월 후의 월 계산하기
	, CAST(u.register_date::date+i.interval_month * '1month'::interval AS date)
	 AS index_date
	, substring(u.register_date,1,7) AS register_month
	, substring(CAST(
	    u.register_date::date + i.interval_month * '1 month'::interval
	AS text),1,7) AS index_month
    FROM
	 mst_users AS u
	CROSS JOIN
	 mst_intervals AS i
)
, action_log_in_month AS (
 SELECT DISTINCT
	user_id
	, substring(stamp,1,7) AS action_month
	FROM 
	 action_log
)
SELECT
-- 사용자 마스터과 액션 로그를 결합한 뒤, 월별로 잔존율 집계
 u.register_month
 , u.index_month
 -- action_month이 NULL이 아니라면 사용자 수 집계
 , SUM(CASE WHEN a.action_month IS NOT NULL THEN 1 ELSE 0 END) AS users
 , AVG(CASE WHEN a.action_month IS NOT NULL THEN 100.0 ELSE 0.0 END)
  AS retention_rate
 FROM
  mst_users_with_index_month AS u
  LEFT JOIN
   action_log_in_month AS a
   ON u.user_id = a.user_id
   AND u.index_month = a.action_month
   GROUP BY
      u.register_month, u.index_month
	  ORDER BY
	   u.register_month, u.index_month
	   ;