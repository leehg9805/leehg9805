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

-- 11-19 사용자별로 RFM을 집계하는 쿼리
WITH
purchase_log AS (
 SELECT
	user_id
	, amount
	-- 타임스탬프를 기반으로 날짜 추출하기
	, substring(stamp, 1, 10) AS dt
	FROM
	 action_log
	WHERE
	 action = 'purchase'
)
, user_rfm AS (
 SELECT
	user_id
	, MAX(dt) AS recent_date
	, CURRENT_DATE - MAX(dt::date) AS recency
	, COUNT(dt) AS frequency
	, SUM(amount) AS monetary
	FROM
	 purchase_log
	GROUP BY
	 user_id
)
SELECT *
FROM
 user_rfm
 ;

-- 11-20 사용자들의 RFM 랭크를 계산하는 쿼리
WITH
purchase_log AS (
 SELECT
	user_id
	, amount
	-- 타임스탬프를 기반으로 날짜 추출하기
	, substring(stamp, 1, 10) AS dt
	FROM
	 action_log
	WHERE
	 action = 'purchase'
),
user_rfm AS (
SELECT 
	user_id
	, MAX(dt) AS recent_date
	, CURRENT_DATE - MAX(dt::date) AS recency
	, COUNT(dt) AS frequency
	, SUM(amount) AS monetary
	FROM
	 purchase_log
	GROUP BY
     user_id
)
, user_rfm_rank AS (
 SELECT
	user_id
	,recent_date
	,recency
	,frequency
	,monetary
	,CASE
	  WHEN recency < 14 THEN 5
	  WHEN recency < 28 THEN 4
	  WHEN recency < 60 THEN 3
	  WHEN recency < 90 THEN 2
	   ELSE 1
	 END AS r
	, CASE
	WHEN 20 <= frequency THEN 5
	WHEN 10 <= frequency THEN 4
	WHEN  5 <= frequency THEN 3
	WHEN  2 <= frequency THEN 2
	WHEN  1  = frequency THEN 1
	END AS f
	, CASE
	WHEN 300000 <= monetary THEN 5
	WHEN 100000 <= monetary THEN 4
	WHEN  30000 <= monetary THEN 3
	WHEN   5000 <= monetary THEN 2
	 ELSE 1
	END AS m
	FROM 
	 user_rfm
) 
SELECT *
FROM
 user_rfm_rank
 ;


-- 11-21 각 그룹의 사람 수를 확인하는 쿼리
WITH
purchase_log AS (
 SELECT
	user_id
	, amount
	-- 타임스탬프를 기반으로 날짜 추출하기
	, substring(stamp, 1, 10) AS dt
	FROM
	 action_log
	WHERE
	 action = 'purchase'
),
user_rfm AS (
SELECT 
	user_id
	, MAX(dt) AS recent_date
	, CURRENT_DATE - MAX(dt::date) AS recency
	, COUNT(dt) AS frequency
	, SUM(amount) AS monetary
	FROM
	 purchase_log
	GROUP BY
     user_id
)
, user_rfm_rank AS (
 SELECT
	user_id
	,recent_date
	,recency
	,frequency
	,monetary
	,CASE
	  WHEN recency < 14 THEN 5
	  WHEN recency < 28 THEN 4
	  WHEN recency < 60 THEN 3
	  WHEN recency < 90 THEN 2
	   ELSE 1
	 END AS r
	, CASE
	WHEN 20 <= frequency THEN 5
	WHEN 10 <= frequency THEN 4
	WHEN  5 <= frequency THEN 3
	WHEN  2 <= frequency THEN 2
	WHEN  1  = frequency THEN 1
	END AS f
	, CASE
	WHEN 300000 <= monetary THEN 5
	WHEN 100000 <= monetary THEN 4
	WHEN  30000 <= monetary THEN 3
	WHEN   5000 <= monetary THEN 2
	 ELSE 1
	END AS m
	FROM 
	 user_rfm
)
, mst_rfm_index AS (
-- 1부터 5까지의 숫자를 가지는 테이블 만들기
SELECT 1 AS rfm_index
	UNION ALL SELECT 2 AS rfm_index
	UNION ALL SELECT 3 AS rfm_index
	UNION ALL SELECT 4 AS rfm_index
	UNION ALL SELECT 5 AS rfm_index
	
)
, rfm_flag AS (
 SELECT
	m.rfm_index
	, CASE WHEN m.rfm_index = r.r THEN 1 ELSE 0 END AS r_flag
	, CASE WHEN m.rfm_index = r.f THEN 1 ELSE 0 END AS f_flag
	, CASE WHEN m.rfm_index = r.m THEN 1 ELSE 0 END AS m_flag
	FROM
	 mst_rfm_index AS m
	 CROSS JOIN
	  user_rfm_rank AS r
)
SELECT
 rfm_index
 ,SUM(r_flag) AS r
 , SUM(f_flag) AS F
 , SUM(m_flag) AS m
 FROM
  rfm_flag
  GROUP BY
   rfm_index
   ORDER BY
    rfm_index DESC
	;
	
-- 11-22 통합 랭크를 계산하는 쿼리
WITH
purchase_log AS (
 SELECT
	user_id
	, amount
	-- 타임스탬프를 기반으로 날짜 추출하기
	, substring(stamp, 1, 10) AS dt
	FROM
	 action_log
	WHERE
	 action = 'purchase'
),
user_rfm AS (
SELECT 
	user_id
	, MAX(dt) AS recent_date
	, CURRENT_DATE - MAX(dt::date) AS recency
	, COUNT(dt) AS frequency
	, SUM(amount) AS monetary
	FROM
	 purchase_log
	GROUP BY
     user_id
)
, user_rfm_rank AS (
	SELECT
	user_id
	,recent_date
	,recency
	,frequency
	,monetary
	,CASE
	  WHEN recency < 14 THEN 5
	  WHEN recency < 28 THEN 4
	  WHEN recency < 60 THEN 3
	  WHEN recency < 90 THEN 2
	   ELSE 1
	 END AS r
	, CASE
	WHEN 20 <= frequency THEN 5
	WHEN 10 <= frequency THEN 4
	WHEN  5 <= frequency THEN 3
	WHEN  2 <= frequency THEN 2
	WHEN  1  = frequency THEN 1
	END AS f
	, CASE
	WHEN 300000 <= monetary THEN 5
	WHEN 100000 <= monetary THEN 4
	WHEN  30000 <= monetary THEN 3
	WHEN   5000 <= monetary THEN 2
	 ELSE 1
	END AS m
	FROM 
	 user_rfm

)
SELECT
 r+f+m AS total_rank
 , r, f, m
 , COUNT(user_id)
 FROM
  user_rfm_rank
  GROUP BY
   r, f, m
   ORDER BY
    total_rank DESC, r DESC, f DESC, m DESC;

-- 11-23 종합 랭크별로 사용자 수를 집게하는 쿼리
WITH
purchase_log AS (
 SELECT
	user_id
	, amount
	-- 타임스탬프를 기반으로 날짜 추출하기
	, substring(stamp, 1, 10) AS dt
	FROM
	 action_log
	WHERE
	 action = 'purchase'
),
user_rfm AS (
SELECT 
	user_id
	, MAX(dt) AS recent_date
	, CURRENT_DATE - MAX(dt::date) AS recency
	, COUNT(dt) AS frequency
	, SUM(amount) AS monetary
	FROM
	 purchase_log
	GROUP BY
     user_id
)
, user_rfm_rank AS (
	SELECT
	user_id
	,recent_date
	,recency
	,frequency
	,monetary
	,CASE
	  WHEN recency < 14 THEN 5
	  WHEN recency < 28 THEN 4
	  WHEN recency < 60 THEN 3
	  WHEN recency < 90 THEN 2
	   ELSE 1
	 END AS r
	, CASE
	WHEN 20 <= frequency THEN 5
	WHEN 10 <= frequency THEN 4
	WHEN  5 <= frequency THEN 3
	WHEN  2 <= frequency THEN 2
	WHEN  1  = frequency THEN 1
	END AS f
	, CASE
	WHEN 300000 <= monetary THEN 5
	WHEN 100000 <= monetary THEN 4
	WHEN  30000 <= monetary THEN 3
	WHEN   5000 <= monetary THEN 2
	 ELSE 1
	END AS m
	FROM 
	 user_rfm

)
SELECT
 r+f+m AS total_rank
 , COUNT(user_id)
 FROM
  user_rfm_rank
  GROUP BY
  total_rank
  ORDER BY
   total_rank DESC;
   
-- 11-24 R과 F를 사용해 2차원 사용자 층의 사용자 수를 집계하는 쿼리
WITH
purchase_log AS (
 SELECT
	user_id
	, amount
	-- 타임스탬프를 기반으로 날짜 추출하기
	, substring(stamp, 1, 10) AS dt
	FROM
	 action_log
	WHERE
	 action = 'purchase'
),
user_rfm AS (
SELECT 
	user_id
	, MAX(dt) AS recent_date
	, CURRENT_DATE - MAX(dt::date) AS recency
	, COUNT(dt) AS frequency
	, SUM(amount) AS monetary
	FROM
	 purchase_log
	GROUP BY
     user_id
)
, user_rfm_rank AS (
	SELECT
	user_id
	,recent_date
	,recency
	,frequency
	,monetary
	,CASE
	  WHEN recency < 14 THEN 5
	  WHEN recency < 28 THEN 4
	  WHEN recency < 60 THEN 3
	  WHEN recency < 90 THEN 2
	   ELSE 1
	 END AS r
	, CASE
	WHEN 20 <= frequency THEN 5
	WHEN 10 <= frequency THEN 4
	WHEN  5 <= frequency THEN 3
	WHEN  2 <= frequency THEN 2
	WHEN  1  = frequency THEN 1
	END AS f
	, CASE
	WHEN 300000 <= monetary THEN 5
	WHEN 100000 <= monetary THEN 4
	WHEN  30000 <= monetary THEN 3
	WHEN   5000 <= monetary THEN 2
	 ELSE 1
	END AS m
	FROM 
	 user_rfm

)
SELECT
 CONCAT('r_', r) AS r_rank
 , COUNT(CASE WHEN f = 5 THEN 1 END) AS f_5
 , COUNT(CASE WHEN f = 4 THEN 1 END) AS f_4
 , COUNT(CASE WHEN f = 3 THEN 1 END) AS f_3
 , COUNT(CASE WHEN f = 2 THEN 1 END) AS f_2
 , COUNT(CASE WHEN f = 1 THEN 1 END) AS f_1
 FROM
  user_rfm_rank
  GROUP BY
   r
   ORDER BY
    r_rank DESC;

	
	
