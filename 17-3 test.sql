DROP TABLE IF EXISTS action_log;
CREATE TABLE action_log(
    session  varchar(255)
  , user_id  varchar(255)
  , action   varchar(255)
  , stamp    varchar(255)
);

INSERT INTO action_log
VALUES
    ('98900e', 'U001', 'view', '2016-11-03 18:00:00')
  , ('98900e', 'U001', 'view', '2016-11-03 20:00:00')
  , ('98900e', 'U001', 'view', '2016-11-03 22:00:00')
  , ('1cf768', 'U002', 'view', '2016-11-03 23:00:00')
  , ('1cf768', 'U002', 'view', '2016-11-04 00:30:00')
  , ('1cf768', 'U002', 'view', '2016-11-04 02:30:00')
  , ('87b575', 'U001', 'view', '2016-11-04 03:30:00')
  , ('87b575', 'U001', 'view', '2016-11-04 04:00:00')
  , ('87b575', 'U001', 'view', '2016-11-04 12:00:00')
  , ('eee2b2', 'U002', 'view', '2016-11-04 13:00:00')
  , ('eee2b2', 'U001', 'view', '2016-11-04 15:00:00')
;

-- 17-5 날짜 집계 범위를 오전 4시부터로 변경하는 쿼리
with
action_log_with_mod_stamp as (
 select *
	-- 4시간 전의 시간 계산하기
	, cast(stamp::timestamp - '4 hours'::interval as text) as mod_stamp
	from action_log
)
select 
 session
 , user_id
 , action
 , stamp
  -- 원래 타임스탬프(raw_date)와, 4시간 후를 나타내는 타임스탬프(mod_date) 추출하기
  , substring(stamp, 1, 10) as raw_date
  , substring(mod_stamp, 1, 10) as mod_date
  from action_log_with_mod_stamp;