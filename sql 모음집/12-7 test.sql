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
  , ('afsd4bag', 'U002', 'view'   ,'2016-10-25 15:00:00')
  , ('675bhjba', 'U002', 'view'   ,'2016-10-30 15:00:00')
  , ('fseg652d', 'U002', 'view'   ,'2016-11-01 15:00:00')
  , ('7a3jc52d', 'U002', 'view'   ,'2016-12-01 15:00:00')
  , ('ga43q56a', 'U003', 'view'   ,'2016-10-01 12:00:00')
  , ('854jcq5m', 'U004', 'view'   ,'2016-10-01 12:00:00')
;



-- 12-23 신규 사용자 수, 리피트 사용자 수, 컴백 사용자 수를 집계하는 쿼리\
WITH
monthly_user_action AS (
  -- 월별 사용자 액션 집약하기
	SELECT DISTINCT
	 u.user_id
	, substring(u.register_date, 1, 7) AS register_month
	, substring(l.stamp, 1, 7) AS action_month
	, substring(CAST(
	    l.stamp::date-interval '1 month' AS text
	), 1, 7) AS action_monthly_priv
	FROM
	 mst_users AS u
	JOIN
	 action_log AS l
	 ON u.user_id = l.user_id
)
, monthly_user_with_type AS (
   -- 월별 사용자 분류 테이블
	SELECT
	 action_month
	, user_id
	, CASE
	-- 등록 월과 액션월이 일치하면 신규 이용자
	WHEN register_month = action_month THEN 'new_user'
	-- 이전 월에 액션이 있다면 리피트 사용자
	WHEN action_monthly_priv
	 =LAG(action_month)
	
	OVER(PARTITION BY user_id ORDER BY action_month)
	THEN 'repeat_user'
	-- 이외의 경우는 컴백 사용자
	 ELSE 'come_back_user'
	END AS c
	, action_monthly_priv
	FROM
	 monthly_user_action
)
 SELECT
  action_month
  -- 특정 달의 MAU
  , COUNT(user_id) AS mau
  , COUNT(CASE WHEN c = 'new_user' THEN 1 END) AS new_users
  , COUNT(CASE WHEN c = 'repeat_user' THEN 1 END) AS repeat_users
  , COUNT(CASE WHEN c = 'come_back_user' THEN 1 END) AS come_back_users
  FROM
   monthly_user_with_type
   GROUP BY
    action_month
	ORDER BY
	 action_month
	 ;

-- 12-24 리피트 사용자를 세분화해서 집계하는 쿼리
WITH
monthly_user_action AS (
  -- 월별 사용자 액션 집약하기
	SELECT DISTINCT
	 u.user_id
	, substring(u.register_date, 1, 7) AS register_month
	, substring(l.stamp, 1, 7) AS action_month
	, substring(CAST(
	    l.stamp::date-interval '1 month' AS text
	), 1, 7) AS action_monthly_priv
	FROM
	 mst_users AS u
	JOIN
	 action_log AS l
	 ON u.user_id = l.user_id
)
, monthly_user_with_type AS (
   -- 월별 사용자 분류 테이블
	SELECT
	 action_month
	, user_id
	, CASE
	-- 등록 월과 액션월이 일치하면 신규 이용자
	WHEN register_month = action_month THEN 'new_user'
	-- 이전 월에 액션이 있다면 리피트 사용자
	WHEN action_monthly_priv
	 =LAG(action_month)
	
	OVER(PARTITION BY user_id ORDER BY action_month)
	THEN 'repeat_user'
	-- 이외의 경우는 컴백 사용자
	 ELSE 'come_back_user'
	END AS c
	, action_monthly_priv
	FROM
	 monthly_user_action
)
, monthly_users AS (
 SELECT
	 m1.action_month
	, COUNT(m1.user_id) AS mau
	
	, COUNT(CASE WHEN m1.c = 'new_user' THEN 1 END) AS new_users
	, COUNT(CASE WHEN m1.c = 'repeat_user' THEN 1 END) AS repeat_users
	, COUNT(CASE WHEN m1.c = 'com_back_user' THEN 1 END) AS come_back_users
	
	, COUNT(
	    CASE WHEN m1.c = 'repeat_user' AND m0.c = 'new_user' THEN 1 END
	) AS new_repeat_users
	, COUNT(
	    CASE WHEN m1.c = 'repeat_user' AND m0.c = 'repeat_user' THEN 1 END
	) AS continuous_repeat_users
	, COUNT(
	    CASE WHEN m1.c = 'repeat_user' AND m0.c = 'come_back_user' THEN 1 END
 	) AS come_back_repeat_users
	
	FROM
	 monthly_user_with_type AS m1
	LEFT OUTER JOIN
	 monthly_user_with_type AS m0
	 ON m1.user_id = m0.user_id
	 AND m1.action_monthly_priv = m0.action_month
	GROUP BY
      m1.action_month
)
SELECT
 *
FROM
 monthly_users
ORDER BY
 action_month;
 
 
-- 12-25 MAU 내역과 MAU 속성들의 반복률을 계산하는 쿼리
WITH
monthly_user_action AS (
  -- 월별 사용자 액션 집약하기
	SELECT DISTINCT
	 u.user_id
	, substring(u.register_date, 1, 7) AS register_month
	, substring(l.stamp, 1, 7) AS action_month
	, substring(CAST(
	    l.stamp::date-interval '1 month' AS text
	), 1, 7) AS action_monthly_priv
	FROM
	 mst_users AS u
	JOIN
	 action_log AS l
	 ON u.user_id = l.user_id
)
, monthly_user_with_type AS (
   -- 월별 사용자 분류 테이블
	SELECT
	 action_month
	, user_id
	, CASE
	-- 등록 월과 액션월이 일치하면 신규 이용자
	WHEN register_month = action_month THEN 'new_user'
	-- 이전 월에 액션이 있다면 리피트 사용자
	WHEN action_monthly_priv
	 =LAG(action_month)
	
	OVER(PARTITION BY user_id ORDER BY action_month)
	THEN 'repeat_user'
	-- 이외의 경우는 컴백 사용자
	 ELSE 'come_back_user'
	END AS c
	, action_monthly_priv
	FROM
	 monthly_user_action
)
, monthly_users AS (
 SELECT
	 m1.action_month
	, COUNT(m1.user_id) AS mau
	
	, COUNT(CASE WHEN m1.c = 'new_user' THEN 1 END) AS new_users
	, COUNT(CASE WHEN m1.c = 'repeat_user' THEN 1 END) AS repeat_users
	, COUNT(CASE WHEN m1.c = 'com_back_user' THEN 1 END) AS come_back_users
	
	, COUNT(
	    CASE WHEN m1.c = 'repeat_user' AND m0.c = 'new_user' THEN 1 END
	) AS new_repeat_users
	, COUNT(
	    CASE WHEN m1.c = 'repeat_user' AND m0.c = 'repeat_user' THEN 1 END
	) AS continuous_repeat_users
	, COUNT(
	    CASE WHEN m1.c = 'repeat_user' AND m0.c = 'come_back_user' THEN 1 END
 	) AS come_back_repeat_users
	
	FROM
	 monthly_user_with_type AS m1
	LEFT OUTER JOIN
	 monthly_user_with_type AS m0
	 ON m1.user_id = m0.user_id
	 AND m1.action_monthly_priv = m0.action_month
	GROUP BY
      m1.action_month
)
SELECT
   action_month
   , mau
   , new_users
   , repeat_users
   , come_back_users
   , new_repeat_users
   , continuous_repeat_users
   , come_back_repeat_users
   
   -- 이전 달에 신규 사용자이면서 해당 월에 신규 리피트 사용자인 사용자의 비율
   , 100.0 * new_repeat_users
    / NULLIF(LAG(new_users) OVER(ORDER BY action_month), 0)
	 AS priv_new_repeat_ratio
   
   -- 이전 달에 리피트 사용자이면서 해당 월에 기존 리피트 사용자인 사용자의 비율
   , 100.0 * continuous_repeat_users
    / NULLIF(LAG(repeat_users) OVER(ORDER BY action_month), 0)
	 AS priv_continuous_repeat_ratio
	 
   -- 이전 달 컴백 사용자이면서 해당 월에 컴백 리피트 사용자인 사용자의 비율
   , 100.0 * come_back_repeat_users
    /NULLIF(LAG(come_back_users) OVER(ORDER BY action_month), 0)
	 AS priv_come_back_repeat_ratio
	 
	 FROM
	  monthly_users
	 ORDER BY
	  action_month
	  ;