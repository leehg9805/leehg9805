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


-- 11-16 구매액 많은 순서로 사용자 그룹을 10등분하는 쿼리
WITH
user_purchase_amount AS (
 SELECT
	user_id
	, SUM(amount) AS purchase_amount
	FROM
	 action_log
	WHERE
	 action = 'purchase'
	GROUP BY
	 user_id
)
, users_with_decile AS (
 SELECT
	user_id
	, purchase_amount
	, ntile(10) OVER (ORDER BY purchase_amount DESC) AS decile
	FROM
	 user_purchase_amount
)
SELECT *
FROM users_with_decile
;

-- 11-17 10분할한 Decile들을 집계하는 쿼리
WITH
user_purchase_amount AS (
 SELECT
	user_id
	, SUM(amount) AS purchase_amount
	FROM
	 action_log
	WHERE
	 action = 'purchase'
	GROUp BY
	 user_id
)
, users_with_decile AS (
 SELECT
	user_id
	, purchase_amount
	, ntile(10) OVER (ORDER BY purchase_amount DESC) AS decile
	FROM
	 user_purchase_amount
)
, decile_with_purchase_amount AS (
 SELECT
	decile
	, SUM(purchase_amount) AS amount
	, AVG(purchase_amount) AS avg_amount
	, SUM(SUM(purchase_amount)) OVER (ORDER BY decile) AS cumulative_amount
	, SUM(SUM(purchase_amount)) OVER () AS total_amount
	FROM
	 users_with_decile
	GROUP BY
	 decile
)
SELECT *
FROM
 decile_with_purchase_amount
 ;

-- 11-18 구매액이 많은 Decile 순서로 구성비와 구성비누계를 계산하는 쿼리
WITH
users_purchase_amount AS (
 SELECT
	user_id
	, SUM(amount) AS purchase_amount
	FROM
	 action_log
	WHERE
	 action = 'purchase'
	GROUP BY
	 user_id
)
, users_with_decile AS (
 SELECT
	user_id
	, purchase_amount
	, ntile(10) OVER (ORDER BY purchase_amount DESC) AS decile
	FROM
	 users_purchase_amount
)
, decile_with_purchase_amount AS (
 SELECT
	 decile
	, SUM(purchase_amount) AS amount
	, AVG(purchase_amount) AS avg_amount
	, SUM(SUM(purchase_amount)) OVER (ORDER BY decile) AS cumulative_amount
	, SUM(SUM(purchase_amount)) OVER () AS total_amount
	FROM
	 users_with_decile
	GROUP BY
	 decile
)
SELECT
 decile
 , amount
 , avg_amount
 , 100.0*amount / total_amount AS total_ratio
 , 100.0*cumulative_amount / total_amount As cumulative_ratio
 FROM
  decile_with_purchase_amount;
