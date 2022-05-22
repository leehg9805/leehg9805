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

-- 11-5 사용자의 생일의 계산하는 쿼리
WITH
mst_users_with_int_birth_date AS(
SELECT
	*
	-- 특정 날짜(2017년 1월 1일)의 정수 표현
	,20170101 AS int_specific_date
	-- 문자열로 구성딘 생년월일을 정수 표현으로 변환
	, CAST(replace(substring(birth_date,1,10),'-','') AS integer) AS int_birth_date
	FROM
	 mst_users
)
, mst_users_with_age AS (
  SELECT
	*
	, floor((int_specific_date-int_birth_date) / 10000) AS age
	FROM
	 mst_users_with_int_birth_date
)
SELECT
  user_id, sex, birth_date, age
  
FROM
 mst_users_with_age
 ;
 
-- 11-6 성별과 연령으로 연령별 구분을 계산하는 쿼리
WITH
mst_users_with_int_birth_date AS(
	SELECT
	*
	-- 특정 날짜(2017년 1월 1일)의 정수 표현
	,20170101 AS int_specific_date
	-- 문자열로 구성딘 생년월일을 정수 표현으로 변환
	, CAST(replace(substring(birth_date,1,10),'-','') AS integer) AS int_birth_date
	FROM
	 mst_users
)
, mst_users_with_age AS (
	 SELECT
	*
	, floor((int_specific_date-int_birth_date) / 10000) AS age
	FROM
	 mst_users_with_int_birth_date
)
, mst_users_with_category AS(
  SELECT
	user_id
	, sex
	, age
	, CONCAT(
	   CASE
		WHEN 20 <= age THEN sex
		ELSE ''
		END
		, CASE
		  WHEN age BETWEEN 4 AND 12 THEN 'C'
		   WHEN age BETWEEN 13 AND 19 THEN 'T'
		    WHEN age BETWEEN 20 AND 34 THEN '1'
		 WHEN age BETWEEN 35 AND 49 THEN '2'
		 WHEN age >= 50 THEN '3'
		 END
	) AS category
	FROM
	 mst_users_with_age
)
SELECT *
FROM
 mst_users_with_category
 ;
 
-- 11-7 연령별 구분의 사람 수를 계산하는 쿼리
WITH
mst_users_with_age AS(
	 SELECT
	*
	, floor((int_specific_date-int_birth_date) / 10000) AS age
	FROM
	 mst_users_with_int_birth_date

)
, mst_users_with_category AS(
 SELECT
	user_id
	, sex
	, age
	, CONCAT(
	   CASE
		WHEN 20 <= age THEN sex
		ELSE ''
		END
		, CASE
		  WHEN age BETWEEN 4 AND 12 THEN 'C'
		   WHEN age BETWEEN 13 AND 19 THEN 'T'
		    WHEN age BETWEEN 20 AND 34 THEN '1'
		 WHEN age BETWEEN 35 AND 49 THEN '2'
		 WHEN age >= 50 THEN '3'
		 END
	) AS category
	FROM
	 mst_users_with_age
) 
SELECT
	category
	, COUNT(1) AS user_count
FROM
	mst_users_with_category
    GROUP BY
	 category
	;
