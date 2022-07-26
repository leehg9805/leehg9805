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
  , ('afsd4bag', 'U002', 'view'   ,'2016-10-10 15:00:00')
;


-- 12-16액션의 계급 마스터와 사용자 액션 플래그의 조합을 산출하는 쿼리
WITH
repeat_interval(index_name, interval_begin_date, interval_end_date) AS (
 VALUES('14 day retention', 8, 14)
)
, action_log_with_index_date AS (
 SELECT
	u.user_id
	, u.register_date
	-- 액션의 날짜와 로그 전체의 최신 날짜를 날짜 자료형으로 변환하기
	, CAST(a.stamp AS date) AS action_date
	, MAX(CAST(a.stamp AS date)) OVER() AS latest_date
	, r.index_name
	
	-- 지표의 대상 기간 시작일과 종료일 계산하기
	, CAST(u.register_date::date + '1 day'::interval*r.interval_begin_date AS date)
	 AS index_begin_date
	, CAST(u.register_date::date + '1 day'::interval*r.interval_end_date AS date)
	 AS index_end_date
	FROM
	 mst_users AS u
	LEFT OUTER JOIN
	 action_log AS a
	ON u.user_id = a.user_id
	CROSS JOIN
	 repeat_interval AS r
)
, user_action_flag AS (
 SELECT
	user_id
	, register_date
	, index_name
	 -- 4. 지표의 대상 기간에 액션을 했는지 플래그로 나타내기
	, SIGN(
	 -- 3. 사용자 별로 대상 기간에 한 액션의 합계 구하기
		SUM(
		-- 1. 대상 기간의 종료일이 로그의 최신 날짜 이전인지 확인
			CASE WHEN index_end_date <= latest_date THEN
			-- 2. 지표의 대상 기간에 액션을 했다면 1, 안 하면 0 지정
			CASE WHEN action_date BETWEEN index_begin_date AND index_end_date
			 THEN 1 ELSE 0
			END
			 END
		)
	) AS index_date_action
	FROM
	 action_log_with_index_date
	GROUP BY
	 user_id, register_date, index_name, index_begin_date, index_end_date
)
, mst_action_bucket(action, min_count, max_count) AS (
  VALUES
	  ('comment', 0, 0)
	, ('comment', 1, 5)
	, ('comment', 6, 10)
	, ('comment', 11, 9999)
	, ('follow', 0, 0)
	, ('follow', 1, 5)
	, ('follow', 6, 10)
	, ('follow', 11, 9999)
)
, mst_user_action_bucket AS (
 -- 사용자 마스터와 액션 단계 마스터 조합하기
	SELECT
	 u.user_id
	, u.register_date
	, a.action
	, a.min_count
	, a.max_count
 FROM
	 mst_users AS u
	 CROSS JOIN
	 mst_action_bucket AS a
)
SELECT *
FROM
 mst_user_action_bucket
ORDER BY
 user_id, action, min_count
 ;
 
-- 12-17 등록 후 7일 동안의 액션 수를 집계하는 쿼리
WITH
repeat_interval(index_name, interval_begin_date, interval_end_date) AS (
 VALUES('14 day retention', 8, 14)
)
, action_log_with_index_date AS (
 SELECT
	u.user_id
	, u.register_date
	-- 액션의 날짜와 로그 전체의 최신 날짜를 날짜 자료형으로 변환하기
	, CAST(a.stamp AS date) AS action_date
	, MAX(CAST(a.stamp AS date)) OVER() AS latest_date
	, r.index_name
	
	-- 지표의 대상 기간 시작일과 종료일 계산하기
	, CAST(u.register_date::date + '1 day'::interval*r.interval_begin_date AS date)
	 AS index_begin_date
	, CAST(u.register_date::date + '1 day'::interval*r.interval_end_date AS date)
	 AS index_end_date
	FROM
	 mst_users AS u
	LEFT OUTER JOIN
	 action_log AS a
	ON u.user_id = a.user_id
	CROSS JOIN
	 repeat_interval AS r
)
, user_action_flag AS (
 SELECT
	user_id
	, register_date
	, index_name
	 -- 4. 지표의 대상 기간에 액션을 했는지 플래그로 나타내기
	, SIGN(
	 -- 3. 사용자 별로 대상 기간에 한 액션의 합계 구하기
		SUM(
		-- 1. 대상 기간의 종료일이 로그의 최신 날짜 이전인지 확인
			CASE WHEN index_end_date <= latest_date THEN
			-- 2. 지표의 대상 기간에 액션을 했다면 1, 안 하면 0 지정
			CASE WHEN action_date BETWEEN index_begin_date AND index_end_date
			 THEN 1 ELSE 0
			END
			 END
		)
	) AS index_date_action
	FROM
	 action_log_with_index_date
	GROUP BY
	 user_id, register_date, index_name, index_begin_date, index_end_date
)
, mst_action_bucket(action, min_count, max_count) AS (
  VALUES
	  ('comment', 0, 0)
	, ('comment', 1, 5)
	, ('comment', 6, 10)
	, ('comment', 11, 9999)
	, ('follow', 0, 0)
	, ('follow', 1, 5)
	, ('follow', 6, 10)
	, ('follow', 11, 9999)
)
, mst_user_action_bucket AS (
 -- 사용자 마스터와 액션 단계 마스터 조합하기
	SELECT
	 u.user_id
	, u.register_date
	, a.action
	, a.min_count
	, a.max_count
 FROM
	 mst_users AS u
	 CROSS JOIN
	 mst_action_bucket AS a
)
, register_action_flag AS (
  -- 등록일에서 7일 후까지의 액션 수를 세고,
  -- 액션 단계와 14일 정착 달성 플래그 계산하기
	SELECT
	 m.user_id
	,m.action
	,m.min_count
	,m.max_count
	,COUNT(a.action) AS action_count
	,CASE
	 WHEN COUNT(a.action) BETWEEN m.min_count AND m.max_count THEN 1
	 ELSE 0
	END AS achive
	, index_name
	, index_date_action
 FROM
     mst_user_action_bucket AS m
	LEFT JOIN
     action_log AS a
	 ON m.user_id = a.user_id
	 AND CAST(a.stamp AS date)
	  BETWEEN CAST(m.register_date AS date)
	    AND CAST(m.register_date AS date) + interval '7 days'
	    AND m.action = a.action
	  LEFT JOIN
	 user_action_flag AS f
	ON m.user_id = f.user_id
	WHERE
	 f.index_date_action IS NOT NULL
	GROUP BY
	 m.user_id
	,m.action
	,m.min_count
	,m.max_count
	,f.index_name
	,f.index_date_action
)
SELECT *
FROM
 register_action_flag
 ORDER BY
  user_id, action, min_count
  ;
  
-- 12-18 등록 후 7일 동안의 액션 횟수별로 14일 정착률을 집계하는 쿼리
WITH
repeat_interval(index_name, interval_begin_date, interval_end_date) AS (
 VALUES('14 day retention', 8, 14)
)
, action_log_with_index_date AS (
 SELECT
	u.user_id
	, u.register_date
	-- 액션의 날짜와 로그 전체의 최신 날짜를 날짜 자료형으로 변환하기
	, CAST(a.stamp AS date) AS action_date
	, MAX(CAST(a.stamp AS date)) OVER() AS latest_date
	, r.index_name
	
	-- 지표의 대상 기간 시작일과 종료일 계산하기
	, CAST(u.register_date::date + '1 day'::interval*r.interval_begin_date AS date)
	 AS index_begin_date
	, CAST(u.register_date::date + '1 day'::interval*r.interval_end_date AS date)
	 AS index_end_date
	FROM
	 mst_users AS u
	LEFT OUTER JOIN
	 action_log AS a
	ON u.user_id = a.user_id
	CROSS JOIN
	 repeat_interval AS r
)
, user_action_flag AS (
 SELECT
	user_id
	, register_date
	, index_name
	 -- 4. 지표의 대상 기간에 액션을 했는지 플래그로 나타내기
	, SIGN(
	 -- 3. 사용자 별로 대상 기간에 한 액션의 합계 구하기
		SUM(
		-- 1. 대상 기간의 종료일이 로그의 최신 날짜 이전인지 확인
			CASE WHEN index_end_date <= latest_date THEN
			-- 2. 지표의 대상 기간에 액션을 했다면 1, 안 하면 0 지정
			CASE WHEN action_date BETWEEN index_begin_date AND index_end_date
			 THEN 1 ELSE 0
			END
			 END
		)
	) AS index_date_action
	FROM
	 action_log_with_index_date
	GROUP BY
	 user_id, register_date, index_name, index_begin_date, index_end_date
)
, mst_action_bucket(action, min_count, max_count) AS (
  VALUES
	  ('comment', 0, 0)
	, ('comment', 1, 5)
	, ('comment', 6, 10)
	, ('comment', 11, 9999)
	, ('follow', 0, 0)
	, ('follow', 1, 5)
	, ('follow', 6, 10)
	, ('follow', 11, 9999)
)
, mst_user_action_bucket AS (
 -- 사용자 마스터와 액션 단계 마스터 조합하기
	SELECT
	 u.user_id
	, u.register_date
	, a.action
	, a.min_count
	, a.max_count
 FROM
	 mst_users AS u
	 CROSS JOIN
	 mst_action_bucket AS a
)
, register_action_flag AS (
  -- 등록일에서 7일 후까지의 액션 수를 세고,
  -- 액션 단계와 14일 정착 달성 플래그 계산하기
	SELECT
	 m.user_id
	,m.action
	,m.min_count
	,m.max_count
	,COUNT(a.action) AS action_count
	,CASE
	 WHEN COUNT(a.action) BETWEEN m.min_count AND m.max_count THEN 1
	 ELSE 0
	END AS achieve
	, index_name
	, index_date_action
 FROM
     mst_user_action_bucket AS m
	LEFT JOIN
     action_log AS a
	 ON m.user_id = a.user_id
	 AND CAST(a.stamp AS date)
	  BETWEEN CAST(m.register_date AS date)
	    AND CAST(m.register_date AS date) + interval '7 days'
	    AND m.action = a.action
	  LEFT JOIN
	 user_action_flag AS f
	ON m.user_id = f.user_id
	WHERE
	 f.index_date_action IS NOT NULL
	GROUP BY
	 m.user_id
	,m.action
	,m.min_count
	,m.max_count
	,f.index_name
	,f.index_date_action
)
SELECT
 action
 , min_count ||'~' || max_count AS count_range
 , SUM(CASE achieve WHEN 1 THEN 1 ELSE 0 END) AS achieve
 , index_name
 , AVG(CASE achieve WHEN 1 THEN 100.0*index_date_action END) AS achieve_index_rate
 FROM
  register_action_flag
  GROUP BY
   index_name, action, min_count, max_count
   ORDER BY
    index_name, action, min_count;
  