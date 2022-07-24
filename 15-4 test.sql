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


-- 15-8 페이지 가치 할당을 계산하는 쿼리
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
, activity_log_with_conversion_assing as(
  select
	session
	,stamp
	,path
	-- 성과에 이르기까지의 접근 로그를 오름차순으로 정렬하기
	, row_number() over(partition by session order by stamp asc) as asc_order
	-- 성과에 이르기까지의 접근 로그에 내림차순으로 순번 붙이기
	, row_number() over(partition by session order by stamp desc) as desc_order
	-- 성과에 이르기까지의 접근 수 세기
	, count(1) over(partition by session) as page_count
	
	-- 1. 성과에 이르기까지의 접근 로그에 균등한 가치 부여
	, 100.0/count(1) over(partition by session) as fair_assign
	
	-- 2. 성과에 이르기까지의 접근 로그의 첫 페이지에 가치 부여
	, case
	   when row_number() over(partition by session order by stamp asc) = 1
	    then 1000.0
	   else 0.0
	end as first_assign
	
	-- 3. 성과에 이르기까지의 접근 로그의 마지막 페이지에 가치 부여하기
	, case
	   when row_number() over(partition by session order by stamp desc) = 1
	     then 1000.0
	   else 0.0
	 end as last_assign
	
	-- 4. 성과에 이르기까지의 접근 로그의 성과 지점에서 가까운 페이지에 높은 가치 부여하기
	, 1000.0
	  * row_number() over(partition by session order by stamp asc)
	     -- 순번 합계로 나누기
	/(count(1) over(partition by session)
	 * (count(1) over(partition by session)+1)
	 /2)
	 as decrease_assign
	
	-- 5. 성과에 이르기까지의 접근 로그의 성과 지점에서 먼 페이지에 높은 가치 부여하기
	, 1000.0
	  * row_number() over(partition by session order by stamp desc)
	     -- 순번 합계로 나누기( N*(N+1)/2)
	  /( count(1) over(partition by session)
	     * (count(1) over(partition by session)+1)
	   /2)
	as increas_assign
	from activity_log_with_conversion_flag
	where
	 -- 컨버전으로 이어지는 세션 로그만 추출
	 has_conversion = 1
	 -- 입력, 확인, 완료 페이지 제외
	 and path not in ('/input', '/confirm', '/complete')
)
select
  session
  ,asc_order
  ,path
  ,fair_assign as fair_a
  ,first_assign as first_a
  ,last_assign as last_a
  ,decrease_assign as dec_a
  ,increas_assign as inc_a
  from
   activity_log_with_conversion_assing
   order by 
   session, asc_order;


-- 15-9 경로별 페이지 가치 합계 구하는 쿼리
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
, activity_log_with_conversion_assing as(
  select
	session
	,stamp
	,path
	-- 성과에 이르기까지의 접근 로그를 오름차순으로 정렬하기
	, row_number() over(partition by session order by stamp asc) as asc_order
	-- 성과에 이르기까지의 접근 로그에 내림차순으로 순번 붙이기
	, row_number() over(partition by session order by stamp desc) as desc_order
	-- 성과에 이르기까지의 접근 수 세기
	, count(1) over(partition by session) as page_count
	
	-- 1. 성과에 이르기까지의 접근 로그에 균등한 가치 부여
	, 100.0/count(1) over(partition by session) as fair_assign
	
	-- 2. 성과에 이르기까지의 접근 로그의 첫 페이지에 가치 부여
	, case
	   when row_number() over(partition by session order by stamp asc) = 1
	    then 1000.0
	   else 0.0
	end as first_assign
	
	-- 3. 성과에 이르기까지의 접근 로그의 마지막 페이지에 가치 부여하기
	, case
	   when row_number() over(partition by session order by stamp desc) = 1
	     then 1000.0
	   else 0.0
	 end as last_assign
	
	-- 4. 성과에 이르기까지의 접근 로그의 성과 지점에서 가까운 페이지에 높은 가치 부여하기
	, 1000.0
	  * row_number() over(partition by session order by stamp asc)
	     -- 순번 합계로 나누기
	/(count(1) over(partition by session)
	 * (count(1) over(partition by session)+1)
	 /2)
	 as decrease_assign
	
	-- 5. 성과에 이르기까지의 접근 로그의 성과 지점에서 먼 페이지에 높은 가치 부여하기
	, 1000.0
	  * row_number() over(partition by session order by stamp desc)
	     -- 순번 합계로 나누기( N*(N+1)/2)
	  /( count(1) over(partition by session)
	     * (count(1) over(partition by session)+1)
	   /2)
	as increas_assign
	from activity_log_with_conversion_flag
	where
	 -- 컨버전으로 이어지는 세션 로그만 추출
	 has_conversion = 1
	 -- 입력, 확인, 완료 페이지 제외
	 and path not in ('/input', '/confirm', '/complete')
)
, page_total_values as (
   -- 페이지 가치 합계 계산
	select
	path
	, sum(fair_assign) as fair_assign
	, sum(first_assign) as first_assing
	, sum(last_assign) as last_assign
   from
	 activity_log_with_conversion_assing
	group by
	 path
	
)
select * from page_total_values;


-- 15-10 경로들의 평균 페이지 가치를 구하는 쿼리
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
, activity_log_with_conversion_assing as(
  select
	session
	,stamp
	,path
	-- 성과에 이르기까지의 접근 로그를 오름차순으로 정렬하기
	, row_number() over(partition by session order by stamp asc) as asc_order
	-- 성과에 이르기까지의 접근 로그에 내림차순으로 순번 붙이기
	, row_number() over(partition by session order by stamp desc) as desc_order
	-- 성과에 이르기까지의 접근 수 세기
	, count(1) over(partition by session) as page_count
	
	-- 1. 성과에 이르기까지의 접근 로그에 균등한 가치 부여
	, 100.0/count(1) over(partition by session) as fair_assign
	
	-- 2. 성과에 이르기까지의 접근 로그의 첫 페이지에 가치 부여
	, case
	   when row_number() over(partition by session order by stamp asc) = 1
	    then 1000.0
	   else 0.0
	end as first_assign
	
	-- 3. 성과에 이르기까지의 접근 로그의 마지막 페이지에 가치 부여하기
	, case
	   when row_number() over(partition by session order by stamp desc) = 1
	     then 1000.0
	   else 0.0
	 end as last_assign
	
	-- 4. 성과에 이르기까지의 접근 로그의 성과 지점에서 가까운 페이지에 높은 가치 부여하기
	, 1000.0
	  * row_number() over(partition by session order by stamp asc)
	     -- 순번 합계로 나누기
	/(count(1) over(partition by session)
	 * (count(1) over(partition by session)+1)
	 /2)
	 as decrease_assign
	
	-- 5. 성과에 이르기까지의 접근 로그의 성과 지점에서 먼 페이지에 높은 가치 부여하기
	, 1000.0
	  * row_number() over(partition by session order by stamp desc)
	     -- 순번 합계로 나누기( N*(N+1)/2)
	  /( count(1) over(partition by session)
	     * (count(1) over(partition by session)+1)
	   /2)
	as increas_assign
	from activity_log_with_conversion_flag
	where
	 -- 컨버전으로 이어지는 세션 로그만 추출
	 has_conversion = 1
	 -- 입력, 확인, 완료 페이지 제외
	 and path not in ('/input', '/confirm', '/complete')
)
, page_total_values as (
   -- 페이지 가치 합계 계산
	select
	path
	, sum(fair_assign) as sum_fair
	, sum(first_assign) as sum_first
	, sum(last_assign) as sum_last
	, sum(decrease_assign) as sum_dec
	, sum(increas_assign)  as sum_inc
   from
	 activity_log_with_conversion_assing
	group by
	 path
	
)
, page_total_cnt as (
  -- 페이지 뷰 계산하기
	 select
	path
	,count(1) as access_cnt  -- 페이지 뷰
	  -- 방문 횟수로 나누고 싶은 경우는 다음 코드 사용
	from 
	 activity_log
	group by
	 path
)
select
 -- 한 번의 방문에 따른 페이지 가치 계산
  s.path
  ,s.access_cnt
  ,v.sum_fair / s.access_cnt as avg_fair
  ,v.sum_first/s.access_cnt as avg_first
  ,v.sum_last / s.access_cnt as avg_last
  ,v.sum_dec / s.access_cnt as avg_dec
  ,v.sum_inc /s.access_cnt as avg_inc
  from
   page_total_cnt as s
   join
   page_total_values as v
   on s.path=v.path
   order by
   s.access_cnt desc;