DROP TABLE IF EXISTS location_1d;
CREATE TABLE location_1d (
    x1 integer
  , x2 integer
);

INSERT INTO location_1d
VALUES
    ( 5 , 10)
  , (10 ,  5)
  , (-2 ,  4)
  , ( 3 ,  3)
  , ( 0 ,  1)
;

DROP TABLE IF EXISTS location_2d;
CREATE TABLE location_2d (
    x1 integer
  , y1 integer
  , x2 integer
  , y2 integer
);

INSERT INTO location_2d
VALUES
    (0, 0, 2, 2)
  , (3, 5, 1, 2)
  , (5, 3, 2, 1)
;


-- 일차원 데이터의 절대값과 제곱 평균 제곱근을 계산하는 쿼리
select 
   abs(x1-x2) as abs
   , sqrt(power(x1-x2,2)) as rms
   from location_1d
   ;
   
-- 이차원 테이블에 대해 제곱 평균 제곱근 (유클리드 거리)을 구하기
select
   sqrt(power(x1-x2,2)+power(y1-y2,2)) as dist
   ,point(x1,y1) <-> point(x2,y2) as dist
   from location_2d
   ;
   