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
    ('0CVKaz', 'U001', 'view', '216.58.220.238', '2016-11-03 18:00:00')
  , ('1QceiB', 'U002', 'view', '98.139.183.24' , '2016-11-03 19:00:00')
  , ('1hI43A', 'U003', 'view', '210.154.149.63', '2016-11-03 20:00:00')
;


-- 17-1 GeoLite2의 CSV 데이터를 로드하는 쿼리
drop table if exists mst_city_ip;
create table mst_city_ip(
  network inet primary key
  , geoname_id integer
	, registered_country_geoname_id integer
	, represented_country_geoname_id integer
	, is_anonymous_proxy boolean
	, is_statelite_provider boolean
	, postal_code varchar(255)
	, latitude numeric
	, longitude numeric
	, accuracy_radius integer
);

drop table if exists mst_location;
create table mst_locations(
   geoname_id integer primary key
	, locale_code varchar(255)
	, continet_code varchar(10)
	, continet_name varchar(255)
	, country_iso_code varchar(10)
	, country_name varchar(255)
	, subdivision_1_iso_code varchar(10)
	, subdivision_1_name varchar(255)
	, subdivision_2_iso_code varchar(10)
	, subdivision_2_name varchar(255)
	, city_name varchar(255)
	, metro_code integer
	, time_zone varchar(255)
);

copy mst_city_ip from '/path/to/GeoLite2-City_Blocks-IPv4.csv' WITH CSV HEADER;
copy mst_location from '/path/to/GeoLite2-City_Locations-en.csv' WITH CSV HEADER;

-- 17-2 액션 로그의 IP 주소로 국가와 지역 정보를 추출하는 쿼리
select 
 a.ip
 , l.continet_name
 , l.coutry_name
 , l.city_name
 , l.time_zone
 from
  action_log as a
  left join
   mst_city_ip as i
   on a.ip::inet << i.network
  left join
   mst_locations as l
   on i.geoname_ip = l.geoname_id
   ;

