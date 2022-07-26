DROP TABLE IF EXISTS exam_scores;
CREATE TABLE exam_scores(
    name    varchar(255)
  , subject varchar(255)
  , score   integer
);

INSERT INTO exam_scores
VALUES
    ('학생A', '언어',  69)
  , ('학생B', '언어',  87)
  , ('학생C', '언어',  65)
  , ('학생D', '언어',  73)
  , ('학생E', '언어',  61)
  , ('학생A', '수학', 100)
  , ('학생B', '수학',  12)
  , ('학생C', '수학',   7)
  , ('학생D', '수학',  73)
  , ('학생E', '수학',  56)
;


-- 24-7 표준편차, 기본값, 편차값을 계산하는 쿼리
select 
 subject
 ,name
 ,score
 -- 과목별로 표준편차 구하기
 , stddev_pop(score) over(partition by subject) as stddev_pop
 -- 과목별 평균 점수 구하기
 , avg(score) over(partition by subject) as avg_score
 -- 점수별로 기준 점수 구하기
 , (score-avg(score) over(partition by subject))
    /stddev_pop(score) over(partition by subject)
	as std_value
	-- 점수별로 편차값 구하기
	, 10.0*(score - avg(score) over(partition by subject))
	/ stddev_pop(score) over(partition by subject)
	+50
	 as deviattion
	from exam_scores
	order by subject, name; 
	
-- 24-8 표준편차
with
exam_stddev_pop as (
  -- 다른 테이블에서 과목별로 표준편차 구해두기
	select 
	 subject
	, stddev_pop(score) as stddev_pop
	from exam_scores
	group by subject
)
select 
   s.subject
   ,s.name
   ,s.score
   ,d.stddev_pop
   ,avg(s.score) over(partition by s.subject) as avg_score
   ,(s.score - avg(s.score) over(partition by s.subject))
     / d.stddev_pop
	 as std_value
	 ,10.0* (s.score-avg(s.score) over(partition by s.subject))
	 /d.stddev_pop
	 +50
	 as deviation
	 from
	  exam_scores as s
	  join
	   exam_stddev_pop as d
	   on s.subject = d.subject
	 order by s.subject, s.name;