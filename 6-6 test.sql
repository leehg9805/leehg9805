-- inet 자료형을 사용한 ip 주소 비교 쿼리
select 
   cast('127.0.0.1' as inet) < cast('127.0.0.2' as inet) as it
   ,cast('127.0.0.1' as inet) > cast('192.168.0.1' as inet) as gt
   ;

-- inet 자료형을 사용해 ip 주소 범위를 다루는 쿼리
select cast('127.0.0.1' as inet) << cast('127.0.0/8' as inet) as is_contained;

-- IP 주소에서 4개의 10진수 부분을 추출하는 쿼리
select 
   ip
   ,cast(split_part(ip,'.',1)as integer) as ip_part_1
   ,cast(split_part(ip,'.',2)as integer) as ip_part_2
   ,cast(split_part(ip,'.',3)as integer) as ip_part_3
   ,cast(split_part(ip,'.',4)as integer) as ip_part_4
  from
  (select '192.168.0.1' as ip) as t
  -- postgreSQL의 경우 명시적으로 자료형 변환 필수
  -- (select cast('192.168.0.1'as text) as ip) as t
  ;

-- ip 주소를 정수 자료형 표기로 변환하는 쿼리
select
 ip
 ,cast(split_part(ip,'.',1)as integer)*2^24
 + cast(split_part(ip,'.',2)as integer)*2^16
 + cast(split_part(ip,'.',3)as integer)*2^8
 + cast(split_part(ip,'.',4)as integer)*2^0
 as ip_integer
 from
 (select cast('192.168.0.1' as text )as ip) as t
 ;
 
 -- ip 주소를 0으로 메우기
 select 
     ip
	 , lpad(split_part(ip,'.',1),3,'0')
	 ||lpad(split_part(ip,'.',2),3,'0')
	 ||lpad(split_part(ip,'.',3),3,'0')
	 ||lpad(split_part(ip,'.',4),3,'0')
     as ip_padding
 from
 (select cast('192.168.0.1' as text) as ip) as t
 ;