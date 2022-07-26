DROP TABLE IF EXISTS invalid_action_log;
CREATE TABLE invalid_action_log(
    stamp     varchar(255)
  , session   varchar(255)
  , user_id   varchar(255)
  , action    varchar(255)
  , category  varchar(255)
  , products  varchar(255)
  , amount    integer
);

INSERT INTO invalid_action_log
VALUES
    ('2016-11-03 18:10:00', '0CVKaz', 'U001', 'purchase', 'drama' , 'D001,D002', 2000)
  , ('2016-11-03 18:00:00', '0CVKaz', 'U001', 'favorite', 'drama' , 'D001'     , NULL)
  , ('2016-11-03 18:00:00', '0CVKaz', 'U001', 'view'    , NULL    , NULL       , NULL)
  , ('2016-11-03 18:01:00', '0CVKaz', 'U001', 'add_cart', 'drama' , 'D002'     , NULL)
  , ('2016-11-03 18:02:00', '0CVKaz', 'U001', 'add_cart', 'drama' , NULL       , NULL)
  , ('2016-11-04 13:00:00', '1QceiB', 'U002', 'purchase', 'drama' , 'D002'     , 1000)
  , (NULL                 , '1QceiB', 'U002', 'purchase', 'action', 'A005,A006', 1000)
;

-- 18-6 로그 데이터의 요건을 만족하는지 확인하는 쿼리
select 
   action
   
   -- session은 반드시 null이 아니어야 함
   , avg(case when session is not null then 1.0 else 0.0 end) as session
   
   -- user_id은 반드시 null이 아니어야 함
   , avg(case when user_id is not null then 1.0 else 0.0 end) as user_id
   
   -- category는 action=view의 경우 null, 이외의 경우 null이 아니어야 함
   , avg(
      case action
	   when 'view' then 
	    case when category is null then 1.0 else 0.0 end
	   else 
	    case when category is not null then 1.0 else 0.0 end 
	   end 
	   
   ) as category
   
   -- products는 action=view의 경우 null, 이외의 경우 null이 아니어야 함
   , avg(
       case action
	    when 'view' then
	     case when products is null then 1.0 else 0.0 end
	   else 
	     case when products is not null then 1.0 else 0.0 end
	   end
   ) as products
   
   -- amount는 action=purchase의 경우 null이 아니어야 하며 이외의 경우는 null
   , avg(
      case
	   when 'purchase' then
	    case when amount is not null then 1.0 else 0.0 end
	   else
	    case when amount is null then 1.0 else 0.0 end
	   end 
   ) as amount 
   
   -- stamp는 반드시 null이 아니어야 함
   , avg(case when stamp is not null then 1.0 else 0.0 end) as stamp
   
   from
    invalid_action_log
   group by
    action
	;
