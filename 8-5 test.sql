-- 유사테이블 만들기

-- 8-9 디바이스 ID와 이름 마스터 테이블을 만드는 쿼리
with
mst_devices as(
          select 1 as device_id, 'PC' as device_name
union all select 2 as device_id, 'SP' as device_name
union all select 3 as device_id, '애플리케이션' as device_name
)
select *
from mst_devices
;

-- 8-10 의사 테이블을 사용해 코드를 레이블로 변환하는 쿼리
with
mst_devices as(
          select 1 as device_id, 'PC' as device_name
union all select 2 as device_id, 'SP' as device_name
union all select 3 as device_id, '애플리케이션' as device_name
)
select 
   u.user_id
   , d.device_name
from
  mst_users as u
  left join
  mst_devices as d
  on u.register_device = d.device_id
;

-- 8-11 values 구문을 사용해 동적으로 테이블 만들기
with
mst_devices(device_id,device_name) as (
  values
    (1,'PC')
   ,(2,'SP')
   ,(3,'애플리케이션')
)
 select *
 from mst_devices
 ;
 
 
-- 8-14 순번으로 가진 유사 테이블을 작성하는 쿼리
with
series as(
      -- 1부터 5까지의 순번 생성하기
      -- PostgreSQL의 경우 generate_series 사용
      select generate_series(1,5) as idx

)
select*
from series
;

