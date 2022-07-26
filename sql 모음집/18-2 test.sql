DROP TABLE IF EXISTS action_log_with_noise;
CREATE TABLE action_log_with_noise(
    stamp       varchar(255)
  , session     varchar(255)
  , action      varchar(255)
  , products    varchar(255)
  , url         text
  , ip          varchar(255)
  , user_agent  text
);

INSERT INTO action_log_with_noise
VALUES
    ('2016-11-03 18:00:00', '1b700', 'view'    , ''    , 'http://www.example.com/detail?id=1', '98.139.183.24' , 'Mozilla/5.0 (compatible; Bingbot/2.0; +http://www.bing.com/bingbot.htm)'                                                 )
  , ('2016-11-03 19:00:00', '1b700', 'add_cart', 'D001', 'http://www.example.com/detail?id=2', '98.139.183.24' , 'Mozilla/5.0 (compatible; Bingbot/2.0; +http://www.bing.com/bingbot.htm)'                                                 )
  , ('2016-11-03 19:00:00', '1b700', 'purchase', 'D001', 'http://www.example.com/detail?id=2', '98.139.183.24' , 'Mozilla/5.0 (compatible; Bingbot/2.0; +http://www.bing.com/bingbot.htm)'                                                 )
  , ('2016-11-03 20:00:00', '0fb22', 'view'    , ''    , 'http://www.example.com/detail?id=3', '210.154.149.63', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0.2 Safari/602.3.12' )
  , ('2016-11-03 21:00:00', '0fb22', 'view'    , ''    , 'http://www.example.com/detail?id=1', '210.154.149.63', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0.2 Safari/602.3.12' )
  , ('2016-11-04 18:00:00', 'fdb83', 'view'    , ''    , 'http://www.example.com/detail?id=2', '127.0.0.1'     , 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36'       )
  , ('2016-11-04 19:00:00', 'fe8df', 'view'    , ''    , 'http://www.example.com/detail?id=3', '192.0.0.10'    , 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36'            )
  , ('2016-11-04 20:00:00', 'fe8df', 'view'    , ''    , 'http://www.example.com/detail?id=1', '192.0.0.10'    , 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36'            )
  , ('2016-11-04 20:00:00', 'fe8df', 'view'    , ''    , 'http://www.example.com/detail?id=1', '192.0.0.10'    , 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36'            )
  , ('2016-11-04 21:00:00', '14bec', 'view'    , ''    , 'http://www.example.com/detail?id=2', '10.0.0.3'      , 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0'                                               )
  , ('2016-11-04 22:00:00', '14bec', 'add_cart', ''    , 'http://www.example.com/detail?id=3', '10.0.0.3'      , 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0'                                               )
  , ('2016-11-04 22:00:00', '694dd', 'view'    , ''    , 'http://www.example.com/detail?id=1', '172.16.0.5'    , ''                                                                                                                        )
  , ('2016-11-04 22:00:00', '7af12', 'view'    , ''    , 'http://www.example.com/detail?id=2', '192.168.0.23'  , 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36')
  , ('2016-11-04 22:00:00', '7af12', 'add_cart', 'D002', 'http://www.example.com/detail?id=3', '192.168.0.23'  , 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36')
  , ('2016-11-04 22:00:00', '7af12', 'purchase', 'D002', 'http://www.example.com/detail?id=3', '192.168.0.23'  , 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36')
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=1', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=1', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=1', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', ''                                                                                                                        )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=1', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=4', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
;


-- 18-3 규칙을 기반으로 크롤러를 제외하는 쿼리
select 
 *
 from
  action_log_with_noise
  where
   not
   -- 크롤러 판정 조건
   ( user_agent like '%bot%'
	or user_agent like '%crawler%'
	or user_agent like '%spider%'
	or user_agent like '%archiver%'
   
   )
;


-- 18-4 마스터 데이터를 사용해 제외하는 쿼리
with
mst_bot_user_agent as (
 select '%bot%' as rule
	union all select '%crawler%' as rule
	union all select '%spider%' as rule
	union all select '%archiver' as rule
)
, filterd_action_log as (
  select 
	 l.stamp, l.session, l.action, l.products
	, l.url, l.ip, l.user_agent
	from 
	 action_log_with_noise as l
	where
	 not exists (
	   select 1
		 from mst_bot_user_agent as m
		 where
		  l.user_agent like m.rule
	 )
	
)
select 
 * 
 from 
  filterd_action_log
  ;

-- 18-5 접근이 많은 사용자 에이전트를 확인하는 쿼리
with
mst_bot_user_agent as (
 select '%bot%' as rule
	union all select '%crawler%' as rule
	union all select '%spider%' as rule
	union all select '%archiver' as rule
)
, filterd_action_log as (
  select 
	 l.stamp, l.session, l.action, l.products
	, l.url, l.ip, l.user_agent
	from 
	 action_log_with_noise as l
	where
	 not exists (
	   select 1
		 from mst_bot_user_agent as m
		 where
		  l.user_agent like m.rule
	 )
	
)
select
   user_agent
   , count(1) as count
   , 100.0
     * sum(count(1)) over(order by count(1) desc
			rows between unbounded preceding and current row)
			/sum(count(1)) over() as cumulative_ratio
		from
		 filterd_action_log
		group by
		 user_agent
		order by
		 count desc
		 ;


