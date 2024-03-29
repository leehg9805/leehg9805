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
  , ('9afaf87c', 'U002', 'purchase', 'action', 'A005,A006', 1000, '2016-11-04 15:00:00')
;


-- 11-9 한 주에 며칠 사용되었는지를 집계하는 쿼리
WITH
action_log_with_dt AS(
 SELECT *
	-- 타임스탬프에서 날짜 추출하기
	, substring(stamp, 1, 10) AS dt
	FROM action_log
)
, action_day_count_per_user As(
SELECT
	user_id
	, COUNT(DISTINCT dt) AS action_day_count
	FROM
	 action_log_with_dt
	WHERE
	-- 2016년 11월 1일부터 11월 7일까지의 한 주 동안을 대상으로 지정
	 dt BETWEEN '2016-11-01' AND '2016-11-07'
	GROUP BY
	 user_id
)
SELECT
 action_day_count
 , COUNT(DISTINCT user_id) AS user_count
 FROM
  action_day_count_per_user
 GROUP BY
  action_day_count
 ORDER BY
  action_day_count
  ;

-- 11-10 구성비와 구성비누계를 계산하는 쿼리
WITH
action_log_with_dt AS(
 SELECT *
	-- 타임스탬프에서 날짜 추출하기
	, substring(stamp, 1, 10) AS dt
	FROM action_log
),
action_day_count_per_user AS(
SELECT
	user_id
	, COUNT(DISTINCT dt) AS action_day_count
	FROM
	 action_log_with_dt
	WHERE
	 dt BETWEEN '2016-11-01' AND '2016-11-07'
	GROUP BY
	 user_id
)
SELECT
  action_day_count
  , COUNT(DISTINCT user_id) AS user_count
  
  -- 구성비
  , 100.0
   * COUNT(DISTINCT user_id)
   / SUM(COUNT(DISTINCT user_id)) OVER()
   AS composition_ratio
   
   -- 구성비누계
   , 100.0
    * SUM(COUNT(DISTINCT user_id))
	   OVER(ORDER BY action_day_count
		   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
		   / SUM(COUNT(DISTINCT user_id)) OVER()
		   AS culmlative_ratio
	FROM
	 action_day_count_per_user
	GROUP BY
	 action_day_count
	ORDER BY
	 action_day_count
	 ;


