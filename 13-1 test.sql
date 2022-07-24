-- 13-1 신청일과 숙박일의 리드 타임을 계산하는 쿼리
WITH
reservations(reservation_id, register_date, visit_date, days) AS (
 values
	 (1, date '2016-09-01', date '2016-10-01',3)
    ,(2, date '2016-09-20', date '2016-10-01',2)
    ,(3, date '2016-09-30', date '2016-11-20',2)
	,(4, date '2016-10-01', date '2017-01-03',2)
	,(5, date '2016-11-01', date '2016-12-28',3)
)
select
  reservation_id
  ,register_date
  ,visit_date
  ,visit_date::date - register_date::date as lead_time
  from
   reservations
   ;
   
-- 13-2 각 단계에서의 리드 타임과 토탈 리드 타임을 계산하는 쿼리
WITH
requests(user_id, product_id, request_date) AS (
 values
	('U001', '1', date '2016-09-01')
	,('U001', '2', date '2016-09-20')
	,('U002', '3', date '2016-09-30')
	,('U003', '4', date '2016-10-01')
	,('U004', '5', date '2016-11-01')
)
, estimates(user_id, product_id, estimate_date) AS(
 values
	('U001', '2', date '2016-09-21')
	,('U002', '3', date '2016-10-15')
	,('U003', '4', date '2016-10-15')
	,('U004', '5', date '2016-12-01')
	
)
, orders(user_id, product_id, order_date) AS (
	values
    ('U001', '2', date '2016-10-01')
	,('U004', '5', date '2016-12-05')
	)
select
 r.user_id
 , r.product_id
 ,e.estimate_date::date - r.request_date::date as estimate_lead_time
 ,o.order_date::date - e.estimate_date::date as order_lead_time
 ,o.order_date::date - r.request_date::date as total_lead_time
 from
 requests as r
  left outer join
   estimates as e
   on r.user_id =e.user_id
   and r.product_id = e.product_id
   left outer join
    orders as o
	on r.user_id = o.user_id
	and r.product_id = o.product_id
	;

-- 13-3 이전 구매일로부터 일수를 계산하는 쿼리
with
purchase_log(user_id, product_id, purchase_date) as (
 values
  ('U001', '1', '2016-09-01')
  , ('U001', '2', '2016-09-20')
  , ('U002', '3', '2016-09-30')
  , ('U001', '4', '2016-10-01')
  , ('U002', '5', '2016-11-01')
)
select
   user_id
   , purchase_date
   , purchase_date::date
    - lag(purchase_date::date)
	    over(
		partition by user_id
		order by purchase_date
		)
		as lead_time
		from
		 purchase_log
		 ;