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


-- 11-11 사용자들의 액션 플래그를 집계하는 쿼리
WITH
user_action_flag AS (
  -- 사용자가 액션을 했으면 1, 안 했으면 0으로 플래그 붙이기
	SELECT
	user_id
	, SIGN(SUM(CASE WHEN action = 'purchase' then 1 ELSE 0 END)) AS has_purchase
	, SIGN(SUM(CASE WHEN action = 'review'   then 1 ELSE 0 END)) AS has_review
	, SIGN(SUM(CASE WHEN action = 'favorite' then 1 ELSE 0 END)) AS has_favorite
FROM
	action_log
   GROUP BY
	user_id
)
SELECT *
FROM user_action_flag;

-- 11-12 모든 액션 조합에 대한 사용자 수 계산하기
WITH
user_action_flag AS(
 SELECT
	user_id
	, SIGN(SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END)) AS has_purchase
	, SIGN(SUM(CASE WHEN action = 'review'   THEN 1 ELSE 0 END)) AS has_review
	, SIGN(SUM(CASE WHEN action = 'favorite' then 1 ELSE 0 END)) AS has_favorite
	FROM
	 action_log
	GROUP BY
	 user_id
	)
	, action_venn_diagram AS (
	  -- CUBE를 사용해서 모든 액션 조합 구하기
	 SELECT
		has_purchase
		, has_review
		, has_favorite
		, COUNT(1) AS users
		FROM
		 user_action_flag
		GROUP BY
		 CUBE(has_purchase, has_review, has_favorite)
	)
	SELECT *
	FROM action_venn_diagram
	ORDER BY
	 has_purchase, has_review, has_favorite
	 ;
	 
-- 11-13 CUBE 구문을 사용하지 않고 표준 SQL 구문만으로 작성한 쿼리
WITH
user_action_flag AS (
 SELECT
	user_id
	, SIGN(SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END)) AS has_purchase
	, SIGN(SUM(CASE WHEN action = 'review'  THEN 1 ELSE 0 END)) As has_review
	, SIGN(SUM(CASE WHEN action = 'favorite' then 1 ELSE 0 END)) AS has_favorite
	FROM
	 action_log
	GROUP by
	 user_id
	
)
, action_venn_diagram AS(
 -- 모든 액션 조합을 개별적으로 구하고 UNION ALL로 결합
	
 -- 3개의 액션을 모두 한 경우 집계
	SELECT has_purchase, has_review, has_favorite, COUNT(1) AS users
	FROM user_action_flag
	GROUP BY has_purchase, has_review, has_favorite
	
 -- 3개의 액션 중에서 2개의 액션을 한 경우 집계
	UNION ALL
	 SELECT NULL AS has_purchase, has_review, has_favorite, COUNT(1) AS users
	 FROM user_action_flag
	 GROUP BY has_review, has_favorite
	UNION ALL
	 SELECT has_purchase, NULL AS has_review, has_favorite, COUNT(1) AS users
	 FROM user_action_flag
	 GROUP BY has_purchase, has_favorite
	UNION ALL
	 SELECT has_purchase, has_review, NULL AS has_favorite, COUNT(1) AS users
	 FROM user_action_flag
     GROUP BY has_purchase, has_review
	
	-- 3개의 액션 중에서 1개의 액션을 한 경우 집계
	UNION ALL
	 SELECT NULL AS has_purchase, NULL AS has_review, has_favorite, COUNT(1) AS users
	 FROM user_action_flag
	 GROUP BY has_favorite
	UNION ALL
	 SELECT NULL AS has_purchase, has_review, NULL AS has_favorite, COUNT(1) AS users
	 FROM user_action_flag
	 GROUP BY has_review
	UNION ALL 
	 SELECT has_purchase, NULL AS has_review, NULL AS has_favorite, COUNT(1) AS users
	 FROM user_action_flag
	 GROUP BY has_purchase
	 
	-- 액션과 관께 없이 모든 사용자 집계
	UNION ALL
	 SELECT 
	  NULL AS has_purchase, NULL AS has_review, NULL AS has_favorite, COUNT(1) AS users
	 FROM user_action_flag
)

SELECT *
FROM action_venn_diagram
ORDER BY 
 has_purchase, has_review, has_favorite
 ;

-- 11-14 유사적으로 NULL을 포함한 레코드를 추가해서 CUBE 구문과 같은 결과를 얻는 쿼리
WITH
user_action_flag AS(
 SELECT
	user_id
	, SIGN(SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END)) AS mod_has_purchase
	, SIGN(SUM(CASE WHEN action = 'review' THEN 1 ELSE 0 END)) AS mod_has_review
	, SIGN(SUM(CASE WHEN action = 'favorite' THEN 1 ELSE 0 END)) AS mod_has_favorite
	FROM
	 action_log
	GROUP BY
	 user_id
)
, action_venn_diagram AS(
 SELECT
	mod_has_purchase AS has_purchase
	, mod_has_review AS has_review
	, mod_has_favorite AS has_favorite
	, COUNT(1) AS users
	FROM
	 user_action_flag
	GROUP BY
	 mod_has_purchase, mod_has_review, mod_has_favorite
	
)
SELECT *
FROM action_venn_diagram
ORDER BY
 has_purchase, has_review, has_favorite
 ;


-- 11-15 벤 다이어그램을 만들기 위해 데이터를 가공하는 쿼리
WITH
user_action_flag AS(
SELECT
	user_id
	, SIGN(SUM(CASE WHEN action = 'purchase' THEN 1 ELSE 0 END)) AS has_purchase
	, SIGN(SUM(CASE WHEN action = 'review' THEN 1 ELSE 0 END)) AS has_review
	, SIGN(SUM(CASE WHEN action = 'favorite' THEN 1 ELSE 0 END)) AS has_favorite
 FROM
	action_log
  GROUP BY
	user_id
	)
	, action_venn_diagram AS(
	SELECT
		has_purchase
		, has_review
		, has_favorite
		, COUNT(1) AS users
	FROM 
	 user_action_flag
	GROUP BY
		CUBE(has_purchase, has_review, has_favorite)
		
		UNION ALL
	 SELECT NULL AS has_purchase, has_review, has_favorite, COUNT(1) AS users
	 FROM user_action_flag
	 GROUP BY has_review, has_favorite
	UNION ALL
	 SELECT has_purchase, NULL AS has_review, has_favorite, COUNT(1) AS users
	 FROM user_action_flag
	 GROUP BY has_purchase, has_favorite
	UNION ALL
	 SELECT has_purchase, has_review, NULL AS has_favorite, COUNT(1) AS users
	 FROM user_action_flag
     GROUP BY has_purchase, has_review
	
	-- 3개의 액션 중에서 1개의 액션을 한 경우 집계
	UNION ALL
	 SELECT NULL AS has_purchase, NULL AS has_review, has_favorite, COUNT(1) AS users
	 FROM user_action_flag
	 GROUP BY has_favorite
	UNION ALL
	 SELECT NULL AS has_purchase, has_review, NULL AS has_favorite, COUNT(1) AS users
	 FROM user_action_flag
	 GROUP BY has_review
	UNION ALL 
	 SELECT has_purchase, NULL AS has_review, NULL AS has_favorite, COUNT(1) AS users
	 FROM user_action_flag
	 GROUP BY has_purchase
	 
	-- 액션과 관께 없이 모든 사용자 집계
	UNION ALL
	 SELECT 
	  NULL AS has_purchase, NULL AS has_review, NULL AS has_favorite, COUNT(1) AS users
	 FROM user_action_flag
	)
	SELECT
	-- 0,1 플래그를 문자열로 가공하기
	 CASE has_purchase
	  WHEN 1 THEN 'purchase' WHEN 0 THEN 'not purchase' ELSE 'any'
	 END AS has_purchase
	 , CASE has_review
	    WHEN 1 THEN 'review' WHEN 0 THEN 'not reciew' ELSE 'any'
	   END AS has_review
	 , CASE has_favorite
	    WHEN 1 THEN 'favorite' WHEN 0 THEN ' not favorite' ELSE 'any'
	  END AS has_favorite
	  , users
	   -- 전체 사용자 수를 기반으로 비율 구하기
	   ,100.0 * users
	   / NULLIF(
	   -- 모든 액션이 NULL인 사용자 수가 전체 사용자 수를 나타내므로
	   -- 해당 레코드의 사용자 수를 window 함수로 구하기
		   SUM(CASE WHEN has_purchase IS NULL
			   AND has_review IS NULL
			   AND has_favorite IS NULL
               THEN users ELSE 0 END) OVER()
	   , 0)
	   AS ratio
	FROM
	 action_venn_diagram
	 ORDER BY
	  has_purchase, has_review, has_favorite
;

