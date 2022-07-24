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
  , ('2017-01-09 12:19:04', '1cf7678e', 'view', 'page'  , '/'            , ''                )
  , ('2017-01-09 12:18:43', '5eb2e107', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:18:43', 'fe05e1d8', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:18:43', '87b5725f', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:20:22', '87b5725f', 'view', 'search', '/search_list' , 'Line'            )
  , ('2017-01-09 12:20:46', '87b5725f', 'view', 'page'  , '/'            , ''                )
  , ('2017-01-09 12:21:26', '87b5725f', 'view', 'page'  , '/search_input', ''                )
  , ('2017-01-09 12:22:51', '87b5725f', 'view', 'search', '/search_list' , 'Station-with-Job')
  , ('2017-01-09 12:24:13', '87b5725f', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:25:25', '87b5725f', 'view', 'page'  , '/'            , ''                )
  , ('2017-01-09 12:18:43', 'eee2bb21', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:18:43', '5d5b0997', 'view', 'detail', '/detail'      , ''                )
  , ('2017-01-09 12:18:43', '111f2996', 'view', 'search', '/search_list' , 'Pref'            )
  , ('2017-01-09 12:19:11', '111f2996', 'view', 'page'  , '/search_input', ''                )
  , ('2017-01-09 12:20:10', '111f2996', 'view', 'page'  , '/'            , ''                )
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
-- 15-17 /detail 페이지 이후의 사용자 흐름을 집계하는 쿼리
with
activity_log_with_lead_path as (
  select
	session
	, stamp
	, path as path0
	 -- 곧바로 접근한 경로 추출하기
	, lead(path, 1) over(partition by session order by stamp asc) as path1
	 -- 이어서 접근한 경로 추출하기
	, lead(path, 2) over(partition by session order by stamp asc) as path2
	from
	 activity_log
	
)
, raw_user_flow as (
  select
	 path0
	 -- 시작 지점 경로로의 접근 수
	, sum(count(1)) over() as count0
	 -- 곧바로 접근한 경로 (존재하지 않는 경우 문자열 null)
	, coalesce(path1, 'null') as path1
	 -- 곧바로 접근한 경로로의 접근 수
	, sum(count(1)) over(partition by path0, path1) as count1
	 -- 이어서 접근한 경로(존재하지 않는 경우 문자열로 'null' 지정)
	, coalesce(path2, 'null') as path2
	 -- 이어서 접근한 경로로의 접근 수
	, count(1) as count2
  from
	 activity_log_with_lead_path
  where
	 -- 상세 페이지를 시작 지점으로 두기\
	 path0 = '/detail'
	group by
	 path0, path1, path2
)
select
   path0
   , count0
   , path1
   , count1
   , 100.0*count1 /count0 as rate1
   , path2
   , count2
   , 100.0*count2 / count1 as rate2
  from
   raw_user_flow
  order by
   count1 desc , count2 desc
   ;
   
-- 15-18 바로 위의 레코드와 같은 값을 가졌을 때 출력하지 않게 데이터 가공
with
activity_log_with_lead_path as (
  select
	session
	, stamp
	, path as path0
	 -- 곧바로 접근한 경로 추출하기
	, lead(path, 1) over(partition by session order by stamp asc) as path1
	 -- 이어서 접근한 경로 추출하기
	, lead(path, 2) over(partition by session order by stamp asc) as path2
	from
	 activity_log
	
)
, raw_user_flow as (
  select
	 path0
	 -- 시작 지점 경로로의 접근 수
	, sum(count(1)) over() as count0
	 -- 곧바로 접근한 경로 (존재하지 않는 경우 문자열 null)
	, coalesce(path1, 'null') as path1
	 -- 곧바로 접근한 경로로의 접근 수
	, sum(count(1)) over(partition by path0, path1) as count1
	 -- 이어서 접근한 경로(존재하지 않는 경우 문자열로 'null' 지정)
	, coalesce(path2, 'null') as path2
	 -- 이어서 접근한 경로로의 접근 수
	, count(1) as count2
  from
	 activity_log_with_lead_path
  where
	 -- 상세 페이지를 시작 지점으로 두기\
	 path0 = '/detail'
	group by
	 path0, path1, path2
)
select
    case
	 when
	  coalesce(
	    -- 바로 위의 레코드가 가진 path0 추출하기(존재하지 않는 경우 not found로 지정)
		  lag(path0)
		   over(order by count1 desc, count2 desc)
		  , 'not found') <> path0
		  then path0
		  end as path0
		  , case
		    when
			 coalesce(
			  lag(path0)
				 over(order by count1 desc, count2 desc)
				 , 'not found') <> path0
				 then count0
				 end as count0
				 , case
				    when
					 coalesce(
					 -- 바로 위의 레코드가 가진 여러 값을 추출할 수 있게 문자열 결합 후 추출하기
						 lag(path0||path1)
						 over(order by count1 desc, count2 desc)
					 , 'not found') <> (path0||path1)
					 then path1
					 end as page1
					 , case 
					     when
						  coalesce(
						   lag(path0||path1)
							  over(order by count1 desc, count2 desc)
						  , 'not found')<>(path0||path1)
						  then count1
						  end as count1
						  , case 
						      when
							   coalesce(
							    lag(path0||path1)
								   over(order by count1 desc, count2 desc)
							   , 'not found') <>(path0||path1)
							   then 100.0*count1/count0
							   end as rate1
							   , case
							    when 
								 coalesce(
								  lag(path0 || path1 || path2)
									 over(order by count1 desc, count2 desc)
								 , 'not found') <> (path0 || path1 || path2)
								 then path2
								 end as page2
								 , case 
								    when
									 coalesce(
									  lag(path0 || path1 || path2)
										 over(order by count1 desc, count2 desc)
									 , 'not found') <> (path0 || path1 || path2)
									 then count2
									 end as count2
									 , case
									    when
										 coalesce(
										  lag(path0 || path1 || path2)
											 over(order by count1 desc, count2 desc)
										 , 'not found') <> (path0 || path1 || path2)
										 then 100.0*count2 / count1
										 end as rate2
										 from
										  raw_user_flow
										  order by
										   count1 desc
										   , count2 desc
										   ;
										   
-- 15-19 /detail 페이지 이전의 사용자 흐름을 집계하는 쿼리
with
activity_log_with_lag_path as (
  select 
	 session
	,stamp
	,path as path0
	 -- 바로 전에 접근한 경로 추출하기(존재하지 않은 경우 문자열 'null' 로 지정)
	,coalesce(lag(path, 1) over(partition by session order by stamp asc), 'null') as path1
	 -- 그 전에 접근한 추출하기(존재하지 않는 경우 문자열 'null'로 지정)
	,coalesce(lag(path, 2) over(partition by session order by stamp asc), 'null') as path2
	from
	  activity_log
	
)
, raw_user_flow as (
  select
	  path0
	-- 시작 지점 경로로의 접근 수
	, sum(count(1)) over() as count0
	, path1
	  -- 바로 전의 경로로의 접근 수
	, sum(count(1)) over(partition by path0, path1) as count1
	, path2
	  -- 그 전에 접근한 경로로의 접근 수
	, count(1) as count2
	from
	 activity_log_with_lag_path
	where
	  -- 상세 페이지를 시작 지점으로 두기
	  path0 = '/detail'
	group by
	  path0, path1, path2
)
select 
   path2
   , count2
   , 100.0*count2 / count1 as rate2
   , path1
   , count1
   , 100.0*count1 / count0 as rate1
   , path0
   , count0
   from
    raw_user_flow
   order by
    count1 desc
	, count2 desc
	;
	