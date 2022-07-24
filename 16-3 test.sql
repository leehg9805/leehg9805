DROP TABLE IF EXISTS form_log;
CREATE TABLE form_log(
    stamp    varchar(255)
  , session  varchar(255)
  , action   varchar(255)
  , path     varchar(255)
  , status   varchar(255)
);

INSERT INTO form_log
VALUES
    ('2016-12-30 00:56:08', '647219c7', 'view', '/regist/input'    , ''     )
  , ('2016-12-30 00:56:08', '9b5f320f', 'view', '/cart/input'      , ''     )
  , ('2016-12-30 00:57:04', '9b5f320f', 'view', '/regist/confirm'  , 'error')
  , ('2016-12-30 00:57:56', '9b5f320f', 'view', '/regist/confirm'  , 'error')
  , ('2016-12-30 00:58:50', '9b5f320f', 'view', '/regist/confirm'  , 'error')
  , ('2016-12-30 01:00:19', '9b5f320f', 'view', '/regist/confirm'  , 'error')
  , ('2016-12-30 00:56:08', '8e9afadc', 'view', '/contact/input'   , ''     )
  , ('2016-12-30 00:56:08', '46b4c72c', 'view', '/regist/input'    , ''     )
  , ('2016-12-30 00:57:31', '46b4c72c', 'view', '/regist/confirm'  , ''     )
  , ('2016-12-30 00:56:08', '539eb753', 'view', '/contact/input'   , ''     )
  , ('2016-12-30 00:56:08', '42532886', 'view', '/contact/input'   , ''     )
  , ('2016-12-30 00:56:08', 'b2dbcc54', 'view', '/contact/input'   , ''     )
  , ('2016-12-30 00:57:48', 'b2dbcc54', 'view', '/contact/confirm' , 'error')
  , ('2016-12-30 00:58:58', 'b2dbcc54', 'view', '/contact/confirm' , ''     )
  , ('2016-12-30 01:00:06', 'b2dbcc54', 'view', '/contact/complete', ''     )
;


-- 16-3 입력 양식 직귀율을 집계하는 쿼리
with
form_with_progress_flag as (
 select 
	 substring(stamp, 1, 10) as dt
	,session
	,sign(
	     sum(case when path in ('/regist/input') then 1 else 0 end)
	) as has_input
	,sign(
	     sum(case when path in ('/regist/confirm', '/regist/complete') then 1 else 0 end)
	) as has_progress
	from form_log
	group by
	 
	dt, session
)
select 
    dt
	,count(1) as input_count
	,sum(case when has_progress = 0 then 1 else 0 end) as bounce_count
	,100.0*avg(case when has_progress = 0 then 1 else 0 end) as bounce_rate
	from
	 form_with_progress_flag
	where 
	 -- 입력 화면에 방문했던 세션만 추출하기
	 has_input = 1
	group by
	 dt
	 ;
	 
	 