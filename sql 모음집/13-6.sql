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
    ('989004ea', 'U001', 'purchase', 'drama' , 'D001,D002', 2000, '2016-10-01 18:10:00')
  , ('989004ea', 'U001', 'view'    , NULL    , NULL       , NULL, '2016-10-01 18:00:00')
  , ('989004ea', 'U001', 'favorite', 'drama' , 'D001'     , NULL, '2016-10-01 18:00:00')
  , ('989004ea', 'U001', 'review'  , 'drama' , 'D001'     , NULL, '2016-10-01 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-10-01 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-10-01 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-10-01 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-10-01 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-10-01 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D002'     , NULL, '2016-10-01 18:01:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001,D002', NULL, '2016-10-01 18:02:00')
  , ('989004ea', 'U001', 'purchase', 'drama' , 'D001,D002', 2000, '2016-11-01 18:10:00')
  , ('47db0370', 'U002', 'add_cart', 'drama' , 'D001'     , NULL, '2016-10-01 19:00:00')
  , ('47db0370', 'U002', 'purchase', 'drama' , 'D001'     , 1000, '2016-11-01 20:00:00')
  , ('47db0370', 'U002', 'add_cart', 'drama' , 'D002'     , NULL, '2016-10-01 20:30:00')
  , ('87b5725f', 'U001', 'add_cart', 'action', 'A004'     , NULL, '2016-10-01 12:00:00')
  , ('87b5725f', 'U001', 'add_cart', 'action', 'A005'     , NULL, '2016-10-01 12:00:00')
  , ('87b5725f', 'U001', 'add_cart', 'action', 'A006'     , NULL, '2016-10-01 12:00:00')
  , ('9afaf87c', 'U002', 'purchase', 'drama' , 'D002'     , 1000, '2016-12-01 13:00:00')
  , ('9afaf87c', 'U002', 'purchase', 'action', 'A005,A006', 1000, '2016-12-01 15:00:00')
;

-- 13-6 사용자들의 등록일부터 경과한 일수별 매출을 계산하는 쿼리
with
index_intervals(index_name, interval_begin_date, interval_end_date) as (
  values
	  ('30 day sales amount', 0, 30)
	, ('45 day sales amount', 0, 45)
	, ('60 day sales amount', 0, 60)
)
, mst_users_with_base_date as(
  select
	 user_id
	-- 기준일로 등록일 사용하기
	, register_date as base_date
	
	
	
	from
	 mst_users
)
 , purchase_log_with_index_date as (
  select
	   u.user_id
	 , u.base_date
	 , cast(p.stamp as date) as action_date
	 , max(cast(p.stamp as date)) over() as lastest_date
	 , substring(p.stamp, 1, 7) as month
	 , p.amount
	 from
	   mst_users_with_base_date as u
	 left outer join
	   action_log as p
	   on u.user_id = p.user_id
	   and p.action = 'purchase'
	 cross join
	   index_intervals as i
	 
 )
 select *
 from
   purchase_log_with_index_date
   ;
   
-- 13-7 월별 등록자수와 경과일수별 매출을 집계하는 쿼리
with
index_intervals(index_name, interval_begin_date, interval_end_date) as (
  values
	  ('30 day sales amount', 0, 30)
	, ('45 day sales amount', 0, 45)
	, ('60 day sales amount', 0, 60)
)
, mst_users_with_base_date as(
  select
	 user_id
	-- 기준일로 등록일 사용하기
	, register_date as base_date
	
	
	
	from
	 mst_users
)
 , purchase_log_with_index_date as (
  select
	   u.user_id 
	 , u.base_date as index_name
	 , cast(p.stamp as date) as action_date
	 , max(cast(p.stamp as date)) over() as lastest_date
	 , substring(p.stamp, 1, 7) as month
	 , p.amount
	 from
	   mst_users_with_base_date as u
	 left outer join
	   action_log as p
	   on u.user_id = p.user_id
	   and p.action = 'purchase'
	 cross join
	   index_intervals as i
	 
 )
 , user_purchase_amount as (
  select
	  user_id
	 ,month
	 ,index_name
	   -- 3. 지표의 대상 기간에 구매한 금액을 사용자별로 합계 내기
	 , sum(
	    -- 1.지표의 대상 기간의 종료일이 로그의 최신 날짜에 포함되었는지 확인하기
		 case when index_end_date <= latest_date then
		 case 
		   when action_date between index_begin_date and index_end_date then amount
		   else 0
		 end
		 end
	 ) as index_date_amount
	 from
	  purchase_log_with_index_date
	 group by
	  user_id, month, index_name, index_begin_date, index_end_date
 )
 select
   month
   ,count(index_date_amount) as users
   ,index_name
   ,count(case when index_date_amount > 0 then user_id end) as purchase_uu
   ,sum(index_date_amount) as total_amount
   ,avg(index_date_amount) as avg_amount
   from
    user_purchase_amount
	group by
	 month, index_name
	order by
	 month, index
	 ;
