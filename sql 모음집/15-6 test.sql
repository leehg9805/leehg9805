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

-- 15-14 ????????? ?????? ????????? ?????? ????????? ???????????? ??????
with
mst_fallout_step as (
  -- ????????? ????????? ????????? ????????? ?????????
	select 1 as step, '/' as path
	union all select 2 as step, '/search_list' as path
	union all select 3 as step, '/detail' as path
	union all select 4 as step, '/input' as path
	union all select 5 as step, '/complete' as path
	
)
, activity_log_with_fallout_step as (
  select 
	 l.session
	, m.step
	, m.path
	  -- ??? ????????? ????????? ?????? ?????? ?????????
	, max(l.stamp) as max_stamp
	, min(l.stamp) as min_stamp
	from
	 mst_fallout_step as m
	join
	 activity_log as l
	 on m.path = l.path
	group by
	 -- ???????????? ?????? ????????? ????????? ????????? ????????????
	l.session, m.step, m.path
	
)
, activity_log_with_mod_fallout_step as (
  select 
	 session
	, step
	, path
	, max_stamp
	  -- ?????? ??????????????? ??? ?????? ?????? ?????????
	, lag(min_stamp)
	  over(partition by session order by step) 
	-- ??????????????? ?????? ?????? ????????? ?????????
	, min(step) over(partition by session) as min_step
	-- ?????? ????????? ????????? ????????? ?????? ?????? ??? ??????
	, count(1)
	    over(partition by session order by step
			  rows between unbounded preceding and current row)
	 as cum_count
	from
	  activity_log_with_fallout_step
)
 select
 *
 from
  activity_log_with_mod_fallout_step
 order by
  session, step
  ;
  
-- 15-15 ????????? ???????????? ????????? ????????? ???????????? ??????
with
mst_fallout_step as (
  -- ????????? ????????? ????????? ????????? ?????????
	select 1 as step, '/' as path
	union all select 2 as step, '/search_list' as path
	union all select 3 as step, '/detail' as path
	union all select 4 as step, '/input' as path
	union all select 5 as step, '/complete' as path
	
)
, activity_log_with_fallout_step as (
  select 
	 l.session
	, m.step
	, m.path
	  -- ??? ????????? ????????? ?????? ?????? ?????????
	, max(l.stamp) as max_stamp
	, min(l.stamp) as min_stamp
	from
	 mst_fallout_step as m
	join
	 activity_log as l
	 on m.path = l.path
	group by
	 -- ???????????? ?????? ????????? ????????? ????????? ????????????
	l.session, m.step, m.path
	
)
, activity_log_with_mod_fallout_step as (
  select 
	 session
	, step
	, path
	, max_stamp
	  -- ?????? ??????????????? ??? ?????? ?????? ?????????
	, lag(min_stamp)
	  over(partition by session order by step) as lag_min_stamp
	-- ??????????????? ?????? ?????? ????????? ?????????
	, min(step) over(partition by session) as min_step
	-- ?????? ????????? ????????? ????????? ?????? ?????? ??? ??????
	, count(1)
	    over(partition by session order by step
			  rows between unbounded preceding and current row)
	 as cum_count
	from
	  activity_log_with_fallout_step
)
, fallout_log as (
  -- ????????? ????????? ????????? ????????? ????????????
	select
	  session
	, step
	, path
	from
	 activity_log_with_mod_fallout_step
	where
	 -- ???????????? ?????? ????????? 1?????? ????????????
	 min_step = 1
	 -- ?????? ?????? ????????? ?????? ????????? ????????? ???????????? ?????? ?????? ?????? ????????? ??????
	and step = cum_count
	 -- ?????? ????????? ??? ?????? ?????????
	 -- null ?????? ?????? ????????? ?????? ?????? ???????????? ???????????? ??????
	and (lag_min_stamp is null
		 or max_stamp >= lag_min_stamp)
)
select
 *
 from
  fallout_log
  order by
   session, step
   ;
   
-- 15-16 ????????? ???????????? ???????????? ??????
with
mst_fallout_step as (
  -- ????????? ????????? ????????? ????????? ?????????
	select 1 as step, '/' as path
	union all select 2 as step, '/search_list' as path
	union all select 3 as step, '/detail' as path
	union all select 4 as step, '/input' as path
	union all select 5 as step, '/complete' as path
	
)
, activity_log_with_fallout_step as (
  select 
	 l.session
	, m.step
	, m.path
	  -- ??? ????????? ????????? ?????? ?????? ?????????
	, max(l.stamp) as max_stamp
	, min(l.stamp) as min_stamp
	from
	 mst_fallout_step as m
	join
	 activity_log as l
	 on m.path = l.path
	group by
	 -- ???????????? ?????? ????????? ????????? ????????? ????????????
	l.session, m.step, m.path
	
)
, activity_log_with_mod_fallout_step as (
  select 
	 session
	, step
	, path
	, max_stamp
	  -- ?????? ??????????????? ??? ?????? ?????? ?????????
	, lag(min_stamp)
	  over(partition by session order by step) as lag_min_stamp
	-- ??????????????? ?????? ?????? ????????? ?????????
	, min(step) over(partition by session) as min_step
	-- ?????? ????????? ????????? ????????? ?????? ?????? ??? ??????
	, count(1)
	    over(partition by session order by step
			  rows between unbounded preceding and current row)
	 as cum_count
	from
	  activity_log_with_fallout_step
)
, fallout_log as (
  -- ????????? ????????? ????????? ????????? ????????????
	select
	  session
	, step
	, path
	from
	 activity_log_with_mod_fallout_step
	where
	 -- ???????????? ?????? ????????? 1?????? ????????????
	 min_step = 1
	 -- ?????? ?????? ????????? ?????? ????????? ????????? ???????????? ?????? ?????? ?????? ????????? ??????
	and step = cum_count
	 -- ?????? ????????? ??? ?????? ?????????
	 -- null ?????? ?????? ????????? ?????? ?????? ???????????? ???????????? ??????
	and (lag_min_stamp is null
		 or max_stamp >= lag_min_stamp)
)
select
   step
   , path
   , count(1) as count
   ,100.0*count(1)
     / first_value(count(1))
	   over(order by step asc rows between unbounded preceding and unbounded following)
	   as first_trans_rate
	   ,100.0*count(1)
	   / lag(count(1)) over(order by step asc)
	   as step_trans_rate
	   from
	    fallout_log
	  group by
	   step,path
	  order by
	   step
	   ;
	   
