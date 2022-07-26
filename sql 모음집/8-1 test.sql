DROP TABLE IF EXISTS app1_mst_users;
CREATE TABLE app1_mst_users (
    user_id varchar(255)
  , name    varchar(255)
  , email   varchar(255)
);

INSERT INTO app1_mst_users
VALUES
    ('U001', 'Sato'  , 'sato@example.com'  )
  , ('U002', 'Suzuki', 'suzuki@example.com')
;

DROP TABLE IF EXISTS app2_mst_users;
CREATE TABLE app2_mst_users (
    user_id varchar(255)
  , name    varchar(255)
  , phone   varchar(255)
);

INSERT INTO app2_mst_users
VALUES
    ('U001', 'Ito'   , '080-xxxx-xxxx')
  , ('U002', 'Tanaka', '070-xxxx-xxxx')
;

-- 8-1 UNION ALL 구문을 사용해 테이블을 세로로 결합하는 쿼리
select 'app1' as app_name, user_id, name, email from app1_mst_users
UNION ALL
select 'app2' as app_name, user_id, name, NULL as email from app2_mst_users;
