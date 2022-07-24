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


-- 16-1 확인 화면에서의 오류율을 집계하는 쿼리
select
  count(*) as confirm_count
  , sum(case when status = 'error' then 1 else 0 end) as error_count
  , avg(case when status = 'error' then 1.0 else 0.0 end) as error_rate
  , sum(case when status = 'error' then 1.0 else 0.0 end) / count(distinct session)
   as error_per_user
  from form_log
  where
    -- 확인 화면 페이지 판정하기
	path = '/regist/confirm'
	;
	
