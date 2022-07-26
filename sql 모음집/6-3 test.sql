DROP TABLE IF EXISTS advertising_stats;
CREATE TABLE advertising_stats (
    dt          varchar(255)
  , ad_id       varchar(255)
  , impressions integer
  , clicks      integer
);

INSERT INTO advertising_stats
VALUES
    ('2017-04-01', '001', 100000,  3000)
  , ('2017-04-01', '002', 120000,  1200)
  , ('2017-04-01', '003', 500000, 10000)
  , ('2017-04-02', '001',      0,     0)
  , ('2017-04-02', '002', 130000,  1400)
  , ('2017-04-02', '003', 620000, 15000)
;

-- 정수 자료형의 데이터를 나누는 쿼리
select
 dt
 , ad_id
 , cast(clicks as double precision)/ impressions as ctr
 , 100.0*clicks/impressions as ctr_as_percent
 from 
    advertising_stats
 where
     dt = '2017-04-01'
 order by
     dt,ad_id
;
-- 0으로 나누는 것을 피해 CTR을 계산하는 쿼리
select
  dt
  , ad_id
  ,case
   when impressions > 0 then 100.0*clicks/impressions
   end as ctr_aspercent_by_case
   ,100.0*clicks / nullif(impressions,0) as ctr_as_percent_by_null
   from
   advertising_stats
   order by
   dt,ad_id
   ;