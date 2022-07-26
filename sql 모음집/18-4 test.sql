DROP TABLE IF EXISTS action_log_with_ip;
CREATE TABLE action_log_with_ip(
    session  varchar(255)
  , user_id  varchar(255)
  , action   varchar(255)
  , ip       varchar(255)
  , stamp    varchar(255)
);

INSERT INTO action_log_with_ip
VALUES
    ('989004ea', 'U001', 'view', '216.58.220.238', '2016-11-03 18:00:00')
  , ('47db0370', 'U002', 'view', '98.139.183.24' , '2016-11-03 19:00:00')
  , ('1cf7678e', 'U003', 'view', '210.154.149.63', '2016-11-03 20:00:00')
  , ('5eb2e107', 'U004', 'view', '127.0.0.1'     , '2016-11-03 21:00:00')
  , ('fe05e1d8', 'U001', 'view', '216.58.220.238', '2016-11-04 18:00:00')
  , ('87b5725f', 'U005', 'view', '10.0.0.3'      , '2016-11-04 19:00:00')
  , ('5d5b0997', 'U006', 'view', '172.16.0.5'    , '2016-11-04 20:00:00')
  , ('111f2996', 'U007', 'view', '192.168.0.23'  , '2016-11-04 21:00:00')
  , ('3efe001c', 'U008', 'view', '192.0.0.10'    , '2016-11-04 22:00:00')
;


-- 18-7 예약 IP 주소를 정의한 마스터 테이블
with
mst_reserved_ip as (
              select '127.0.0.0/8' as network, 'localhost' as description
	union all select '10.0.0.0/8'  as network, 'Private network' as description
	union all select '172.16.0.0/12' as network, 'Private network' as description
	union all select '192.0.0.0/24' as network, 'Private network' as description
	union all select '192.168.0.0/16' as network, 'Private network' as description
	
)
select *
from mst_reserved_ip
;

-- 18-8 inet 자료형을 사용해 IP 주소를 판정하는 쿼리
with
mst_reserved_ip as (
              select '127.0.0.0/8' as network, 'localhost' as description
	union all select '10.0.0.0/8'  as network, 'Private network' as description
	union all select '172.16.0.0/12' as network, 'Private network' as description
	union all select '192.0.0.0/24' as network, 'Private network' as description
	union all select '192.168.0.0/16' as network, 'Private network' as description
	
)
, action_log_with_reserved_ip as (
  select 
	  l.user_id
	, l.ip
	, l.stamp
	, m.network
	, m.description
	from
	 action_log_with_ip as l
	 left join
	   mst_reserved_ip as m
	on l.ip::inet << m.network::inet
)
select *
from action_log_with_reserved_ip;

-- 18-9 예약 IP 주소의 로그를 제외하는 쿼리
with
mst_reserved_ip as (
              select '127.0.0.0/8' as network, 'localhost' as description
	union all select '10.0.0.0/8'  as network, 'Private network' as description
	union all select '172.16.0.0/12' as network, 'Private network' as description
	union all select '192.0.0.0/24' as network, 'Private network' as description
	union all select '192.168.0.0/16' as network, 'Private network' as description
	
)
, action_log_with_reserved_ip as (
  select 
	  l.user_id
	, l.ip
	, l.stamp
	, m.network
	, m.description
	from
	 action_log_with_ip as l
	 left join
	   mst_reserved_ip as m
	on l.ip::inet << m.network::inet
)
select *
from action_log_with_reserved_ip
where network is null;

-- 18-10 네트워크 범위를 나타내는 처음과 끝 IP 주소를 부여하는 쿼리
with
mst_reserved_ip_with_range as (
  -- 마스터 테이블에 네트워크 범위에 해당하는 ip 주소의 최솟값과 최댓값 추가하기
	select '127.0.0.0/8' as network
	, '127.0.0.0'   as network_start_ip
	, '127.255.255.255' as network_last_ip
	, 'localhost'   as description
	
	union all
	 select '10.0.0.0/8' as network
	 , '10.0.0.0'   as network_start_ip
	 , '10.255.255.255' as network_last_ip
	 , 'Private network' as description
	
	union all
	 select '172.16.0.0/12' as network
	 , '172.16.0.0'   as network_start_ip
	 , '172.31.255.255' as network_last_ip
	 , 'Private network' as description
	
	union all
	 select '192.0.0.0/24' as network
	 , '192.0.0.0'   as network_start_ip
	 , '192.0.0.255' as network_last_ip
	 , 'Private network' as description
	
	union all
	 select '192.168.0.0/16' as network
	 , '192.168.0.0'   as network_start_ip
	 , '192.168.255.255' as network_last_ip
	 , 'Private network' as description

)
select *
from mst_reserved_ip_with_range;

-- 18-11 ip 주소를 0으로 메운 문자열로 변환하고, 특정 IP 로그를 배제하는 쿼리
with
mst_reserved_ip_with_range as (
  -- 마스터 테이블에 네트워크 범위에 해당하는 ip 주소의 최솟값과 최댓값 추가하기
	select '127.0.0.0/8' as network
	, '127.0.0.0'   as network_start_ip
	, '127.255.255.255' as network_last_ip
	, 'localhost'   as description
	
	union all
	 select '10.0.0.0/8' as network
	 , '10.0.0.0'   as network_start_ip
	 , '10.255.255.255' as network_last_ip
	 , 'Private network' as description
	
	union all
	 select '172.16.0.0/12' as network
	 , '172.16.0.0'   as network_start_ip
	 , '172.31.255.255' as network_last_ip
	 , 'Private network' as description
	
	union all
	 select '192.0.0.0/24' as network
	 , '192.0.0.0'   as network_start_ip
	 , '192.0.0.255' as network_last_ip
	 , 'Private network' as description
	
	union all
	 select '192.168.0.0/16' as network
	 , '192.168.0.0'   as network_start_ip
	 , '192.168.255.255' as network_last_ip
	 , 'Private network' as description

)
, action_log_with_ip_varchar as (
  -- 액션 로그의 IP 주소를 0으로 메운 문자열로 표현하기

  select 
   *
   , lpad(split_part(ip, '.',1),3,'0')
    || lpad(split_part(ip,'.',2),3,'0')
	|| lpad(split_part(ip,'.',3),3,'0')
	|| lpad(split_part(ip,'.',4),3,'0')
	as ip_varchar
	from 
	 action_log_with_ip
)
, mst_reserved_ip_with_varchar_range as (
	
	 select 
   *
   , lpad(split_part(network_start_ip, '.',1),3,'0')
    || lpad(split_part(network_start_ip,'.',2),3,'0')
	|| lpad(split_part(network_start_ip,'.',3),3,'0')
	|| lpad(split_part(network_start_ip,'.',4),3,'0')
	as network_start_ip_varchar
	
	, lpad(split_part(network_last_ip, '.',1),3,'0')
    || lpad(split_part(network_last_ip,'.',2),3,'0')
	|| lpad(split_part(network_last_ip,'.',3),3,'0')
	|| lpad(split_part(network_last_ip,'.',4),3,'0')
	as network_last_ip_varchar
	
	from
	 mst_reserved_ip_with_range

)
-- 0으로 메운 문자열로 표현한 IP 주소로, 네트워크로 범위에 포함되는지 판정하기
select 
  l.user_id
  , l.ip
  , l.ip_varchar
  , l.stamp
  from
   action_log_with_ip_varchar as l
  cross join
   mst_reserved_ip_with_varchar_range as m
  group by
  l.user_id, l.ip, l.ip_varchar, l.stamp
  having 
   sum(case when l.ip_varchar
	   between m.network_start_ip_varchar and m.network_last_ip_varchar
	   then 1 else 0 end) =0
	   ;

