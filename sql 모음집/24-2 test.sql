DROP TABLE IF EXISTS action_counts;
CREATE TABLE action_counts(
    user_id        varchar(255)
  , product        varchar(255)
  , view_count     integer
  , purchase_count integer
);

INSERT INTO action_counts
VALUES
    ('U001', 'D001',  2, 1)
  , ('U001', 'D002', 16, 0)
  , ('U001', 'D003', 14, 0)
  , ('U001', 'D004', 15, 0)
  , ('U001', 'D005', 21, 1)
  , ('U002', 'D001', 10, 1)
  , ('U002', 'D003', 28, 0)
  , ('U002', 'D005', 28, 1)
  , ('U003', 'D001', 49, 0)
  , ('U003', 'D004', 29, 1)
  , ('U003', 'D005', 24, 1)
;


-- 24-5 열람 수와 구매 수에 Min-Max 정규화를 적용하는 쿼리
select 
  user_id
  ,product
  ,view_count as v_count
  ,purchase_count as p_count
  ,1.0 *(view_count - min(view_count)over())
  / nullif((max(view_count) over()-min(view_count) over()), 0)
  as norm_v_count
  , 1.0*(purchase_count - min(purchase_count) over())
  /nullif((max(purchase_count)over()- min(purchase_count)over()),0)
  as norm_p_count
 from action_counts
 order by user_id, product;
 
-- 24-6 시그모이드 함수를 사용해 변환하는 쿼리
select 
  user_id
  , product 
  , view_count as v_count
  , purchase_count as p_count
    -- 게인을 0.1로 사용한 시그모이드 함수
  , 2.0/(1+exp(-0.1*view_count)) - 1.0 as sigm_v_count
    -- 게인을 10으로 사용한 시그모이드 함수
  , 2.0/ (1+exp(-10.0*purchase_count)) - 1.0 as sigm_p_count
  from action_counts
  order by user_id, product;