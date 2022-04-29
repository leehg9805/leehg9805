DROP TABLE IF EXISTS daily_kpi;
CREATE TABLE daily_kpi (
    dt        varchar(255)
  , indicator varchar(255)
  , val       integer
);

INSERT INTO daily_kpi
VALUES
    ('2017-01-01', 'impressions', 1800)
  , ('2017-01-01', 'sessions'   ,  500)
  , ('2017-01-01', 'users'      ,  200)
  , ('2017-01-02', 'impressions', 2000)
  , ('2017-01-02', 'sessions'   ,  700)
  , ('2017-01-02', 'users'      ,  250)
;

DROP TABLE IF EXISTS purchase_detail_log;
CREATE TABLE purchase_detail_log (
    purchase_id integer
  , product_id  varchar(255)
  , price       integer
);

INSERT INTO purchase_detail_log
VALUES
    (100001, 'A001', 3000)
  , (100001, 'A002', 4000)
  , (100001, 'A003', 2000)
  , (100002, 'D001', 5000)
  , (100002, 'D002', 3000)
  , (100003, 'A001', 3000)
;

select
   dt
   ,max(case when indicator = 'impressions' then val end) as impressions
   ,max(case when indicator = 'sessions'  then val end) as sessions
   ,max(case when indicator = 'users'     then val end) as users
   from daily_kpi
   group by dt
   order by dt
   ;
   
-- 행을 집약해서 쉼표로 구분된 문자열로 변환하기
select 
   purchase_id
   
   --상품 ID를 배열에 집약하고 쉼표로 구분된 문자열로 변환하기
   ,string_agg(product_id, ',') as product_ids
   
   ,sum(price) as amount
 from purchase_detail_log
 group by purchase_id
 order by purchase_id
 ;
 
 