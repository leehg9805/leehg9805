DROP TABLE IF EXISTS activity_log;
CREATE TABLE activity_log(
    stamp        varchar(255)
  , session      varchar(255)
  , action       varchar(255)
  , option       varchar(255)
  , path         varchar(255)
  , search_type  varchar(255)
);

INSERT INTO activity_log
VALUES
    ('2017-01-09 12:18:43', '989004ea', 'view', 'search', '/search_list' , 'Area-L-with-Job' )
  , ('2017-01-09 12:19:27', '989004ea', 'view', 'page'  , '/search_input', ''                )
  , ('2017-01-09 12:20:03', '989004ea', 'view', 'search', '/search_list' , 'Pref'            )
  , ('2017-01-09 12:18:43', '47db0370', 'view', 'search', '/search_list' , 'Area-S'          )
  , ('2017-01-09 12:18:43', '1cf7678e', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:19:04', '1cf7678e', 'view', 'page'  , ''             , ''                )
  , ('2017-01-09 12:18:43', '5eb2e107', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:18:43', 'fe05e1d8', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:18:43', '87b5725f', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:20:22', '87b5725f', 'view', 'search', '/search_list' , 'Line'            )
  , ('2017-01-09 12:20:46', '87b5725f', 'view', 'page'  , ''             , ''                )
  , ('2017-01-09 12:21:26', '87b5725f', 'view', 'page'  , '/search_input', ''                )
  , ('2017-01-09 12:22:51', '87b5725f', 'view', 'search', '/search_list' , 'Station-with-Job')
  , ('2017-01-09 12:24:13', '87b5725f', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:25:25', '87b5725f', 'view', 'page'  , ''             , ''                )
  , ('2017-01-09 12:18:43', 'eee2bb21', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:18:43', '5d5b0997', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:18:43', '111f2996', 'view', 'search', '/search_list' , 'Pref'            )
  , ('2017-01-09 12:19:11', '111f2996', 'view', 'page'  , '/search_input', ''                )
  , ('2017-01-09 12:20:10', '111f2996', 'view', 'page'  , ''             , ''                )
  , ('2017-01-09 12:21:14', '111f2996', 'view', 'page'  , '/search_input', ''                )
  , ('2017-01-09 12:18:43', '3efe001c', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:18:43', '9afaf87c', 'view', 'search', '/search_list' , ''                )
  , ('2017-01-09 12:20:18', '9afaf87c', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:21:39', '9afaf87c', 'view', 'page'  , '/input'       , ''                )
  , ('2017-01-09 12:22:52', '9afaf87c', 'view', 'page'  , '/confirm'     , ''                )
  , ('2017-01-09 12:23:00', '9afaf87c', 'view', 'page'  , '/complete'    , ''                )
  , ('2017-01-09 12:18:43', 'd45ec190', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:18:43', '0fe39581', 'view', 'search', '/search_list' , 'Area-S'          )
  , ('2017-01-09 12:18:43', '36dd0df7', 'view', 'search', '/search_list' , 'Pref-with-Job'   )
  , ('2017-01-09 12:19:49', '36dd0df7', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:18:43', '8cc03a54', 'view', 'search', '/search_list' , 'Area-L'          )
  , ('2017-01-09 12:18:44', '8cc03a54', 'view', 'page'  , '/input'       , 'Area-L'          )
  , ('2017-01-09 12:18:45', '8cc03a54', 'view', 'page'  , '/confirm'     , 'Area-L'          )
  , ('2017-01-09 12:18:46', '8cc03a54', 'view', 'page'  , '/complete'    , 'Area-L'          )
  , ('2017-01-09 12:18:43', 'cabf98e8', 'view', 'page'  , '/search_input', ''                )
;


-- 15-6 컨버전 페이지보다 이전 접근에 플래그를 추가하는 쿼리
with
activity_log_with_conversion_flag as (
 select
	session
	, stamp
	, path
	 -- 성과를 발생시키는 컨버전 페이지의 이전 접근에 플래그 추가
	, sign(sum(case when path = '/complete' then 1 else 0 end)
		   over(partition by session order by stamp desc
			   rows between unbounded preceding and current row))
	as has_conversion
	from
	 activity_log
)
select *
from
 activity_log_with_conversion_flag
 order by
  session, stamp
  ;


-- 15-7 경로들의 방문 횟수와 구성 수를 집계하는 쿼리
with
activity_log_with_conversion_flag as (
	select
	session
	, stamp
	, path
	 -- 성과를 발생시키는 컨버전 페이지의 이전 접근에 플래그 추가
	, sign(sum(case when path = '/complete' then 1 else 0 end)
		   over(partition by session order by stamp desc
			   rows between unbounded preceding and current row))
	as has_conversion
	from
	 activity_log
)
select
  path
  -- 방문횟수
  ,count(distinct session) as sessions
  -- 성과 수
  ,sum(has_conversion) as conversions
  -- <성과 수>/<방문 횟수>
  ,1.0 * sum(has_conversion)/count(distinct session) as cvr
  from
   activity_log_with_conversion_flag
   -- 경로별로 집약
   group by path
   ;