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
  , ('U004', 'F', '1954-05-21', '2016-10-05', 'pc' , NULL        )
  , ('U005', 'M', '1987-11-23', '2016-10-05', 'sp' , NULL        )
  , ('U006', 'F', '1950-01-21', '2016-10-10', 'pc' , '2016-10-10')
  , ('U007', 'F', '1950-07-18', '2016-10-10', 'app', NULL        )
  , ('U008', 'F', '2006-12-09', '2016-10-10', 'sp' , NULL        )
  , ('U009', 'M', '2004-10-23', '2016-10-15', 'pc' , NULL        )
  , ('U010', 'F', '1987-03-18', '2016-10-16', 'pc' , NULL        )
;

DROP TABLE IF EXISTS action_log;
CREATE TABLE action_log(
    session  varchar(255)
  , user_id  varchar(255)
  , action   varchar(255)
  , category varchar(255)
  , products varchar(255)
  , amount   integer
  , stamp    varchar(255)
);

INSERT INTO action_log
VALUES
    ('989004ea', 'U001', 'purchase', 'drama' , 'D001,D002', 2000, '2016-11-03 18:10:00')
  , ('989004ea', 'U001', 'view'    , NULL    , NULL       , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'favorite', 'drama' , 'D001'     , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'review'  , 'drama' , 'D001'     , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D002'     , NULL, '2016-11-03 18:01:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001,D002', NULL, '2016-11-03 18:02:00')
  , ('989004ea', 'U001', 'purchase', 'drama' , 'D001,D002', 2000, '2016-11-03 18:10:00')
  , ('47db0370', 'U002', 'add_cart', 'drama' , 'D001'     , NULL, '2016-11-03 19:00:00')
  , ('47db0370', 'U002', 'purchase', 'drama' , 'D001'     , 1000, '2016-11-03 20:00:00')
  , ('47db0370', 'U002', 'add_cart', 'drama' , 'D002'     , NULL, '2016-11-03 20:30:00')
  , ('87b5725f', 'U001', 'add_cart', 'action', 'A004'     , NULL, '2016-11-04 12:00:00')
  , ('87b5725f', 'U001', 'add_cart', 'action', 'A005'     , NULL, '2016-11-04 12:00:00')
  , ('87b5725f', 'U001', 'add_cart', 'action', 'A006'     , NULL, '2016-11-04 12:00:00')
  , ('9afaf87c', 'U002', 'purchase', 'drama' , 'D002'     , 1000, '2016-11-04 13:00:00')
  , ('9afaf87c', 'U001', 'purchase', 'action', 'A005,A006', 1000, '2016-11-04 15:00:00')
;

-- 11-1 액션 수와 비율을 계산하는 쿼리
WITH
stats AS(
 -- 로그 전체의 유니크 사용자 수 구하기
	SELECT COUNT(DISTINCT session) AS total_uu
	FROM action_log
)
SELECT 
  l.action
  -- 액션 UU
  ,COUNT(DISTINCT l.session) AS action_uu
  -- 액션의 수
  ,COUNT(1) AS action_count
  -- 전체 UU
  ,s.total_uu
  -- 사용률:<액션 UU>/<전체 UU>
  ,100.0*COUNT(DISTINCT l.session) / s.total_uu as usage_rate
  -- 1인당 액션 수: <액션 수> / <액션 UU>
  ,1.0*COUNT(1)/COUNT(DISTINCT l.session) AS count_per_user
  from
   action_log AS l
   -- 로그 전체의 유니크 사용자 수를 모든 레코드에 결합하기
   CROSS JOIN
    stats AS s
	group by
	 l.action, s.total_uu
	 ;

-- 로그인 상태를 판별하는 쿼리
WITH
action_log_with_status AS (
 SELECT
	session
	, user_id
	, action
	-- user_id가 NULL 또는 빈 문자가 아닌 경우 login이라고 판정하기
	, CASE WHEN COALESCE(user_id,'')<>''THEN 'login' ELSE 'guest' END
	  AS login_status
	FROM
	 action_log
	)
	SELECT *
	FROM
	 action_log_with_status
;

-- 11-2 로그인 상태를 판별하는 쿼리
WITH
action_log_with_status AS (
 SELECT
	session
	, user_id
	, action
	-- user_id가 NULL 또는 빈 문자가 아닌 경우 login이라고 판정
	, CASE WHEN COALESCE(user_id,'')<>'' THEN 'login' ELSE 'guest' END
	AS login_status
	FROM
	 action_log
)
SELECT *
FROM
 action_log_with_status
 ;
-- 11-3 로그인 상태에 따라 액션 수 등을 따로 집계하는 쿼리
WITH
action_log_with_status AS(
SELECT
	session
	, user_id
	, action
	, CASE WHEN COALESCE(user_id,'')<>'' then 'login' ELSE 'guest' end
	AS login_status
	from
	 action_log
	)
	SELECT
	  COALESCE(action, 'all') AS action
	  , COALESCE(login_status, 'all') AS login_status
	  , COUNT(DISTINCT session) AS action_uu
	  , COUNT(1)  AS action_count
	  FROM
	   action_log_with_status
	   GROUP BY
	   ROLLUP(action,login_status)
	   ;
	   
-- 11-4 회원 상태를 판별하는 쿼리
WITH
action_log_with_status AS (
 SELECT
	session
	, user_id
	, action
	-- 로그를 타임스탬프 순서로 나열하고, 한 번이라도 로그인할 사용자일 겨우,
	-- 이후의 모든 로그 상태를 member로 설정
	, CASE
	   WHEN
	     COALESCE(MAX(user_id)
			OVER(PARTITION BY session ORDER BY stamp
				ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)	 
				 ,'')<> ''
	THEN 'member'
	ELSE 'none'
	END AS member_status
	, stamp
	FROM
	 action_log
)

SELECT *
FROM
 action_log_with_status
 ;
 
 


