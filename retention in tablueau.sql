## qxf_user_retention_vender  

SELECT a.year_month year_month,
        b.retention_year_month retention_year_month,
        a.vender_id vender_id,
        b.retention_vender_id retention_vender_id,
       count(distinct a.webuser_id ) user_cnt
FROM
  (SELECT DISTINCT  substr(order_create_time,1,7) year_month,
                    vender_id,
                    webuser_id 
   FROM dmall_order.wm_order
   WHERE order_status = 1024
     AND dt >= '20170101') a
JOIN
  (SELECT DISTINCT  substr(order_create_time,1,7) retention_year_month,
                    vender_id retention_vender_id,
                    webuser_id  retention_webuser_id
   FROM dmall_order.wm_order
   WHERE order_status = 1024
     AND dt >= '20170101') b 
     ON a.webuser_id = b.retention_webuser_id
     where  a.year_month <= b.retention_year_month
     group by  a.year_month,
        b.retention_year_month,
        a.vender_id,
        b.retention_vender_id

#改，新增字段，商家，将天津物美的用户分出来，时间用订单完成时间
SELECT a.year_month year_month,
       b.year_month retention_year_month,
       a.vender_id vender_id,
       b.vender_id retention_vender_id,
       a.vender_name vender_name,
       b.vender_name retention_vender_name,
       count(DISTINCT a.webuser_id) user_cnt
FROM
  (SELECT DISTINCT substr(a.order_complete_time,1,7) year_month,
                   CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN 1
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN 85
                       ELSE b.vender_id
                   END AS vender_id,
                   CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN '天津物美'
                       ELSE b.vender_name
                   END AS vender_name,
                   a.webuser_id
   FROM dmall_order.wm_order a
   JOIN dm_data.dim_store b ON a.erp_store_id = b.store_id
   WHERE a.order_status = 1024
     AND a.dt >= '20161201'
     and a.order_complete_time >= '2017-01-01 00:00:00') a
JOIN
  (SELECT DISTINCT substr(a.order_complete_time,1,7) year_month,
                   CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN 1
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN 85
                       ELSE b.vender_id
                   END AS vender_id,
                   CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN '天津物美'
                       ELSE b.vender_name
                   END AS vender_name,
                   a.webuser_id
   FROM dmall_order.wm_order a
   JOIN dm_data.dim_store b ON a.erp_store_id = b.store_id
   WHERE a.order_status = 1024
    and a.dt >= '20161201'
     and a.order_complete_time >= '2017-01-01 00:00:00'
     ) b ON a.webuser_id = b.webuser_id
WHERE a.year_month <= b.year_month
GROUP BY a.year_month,
         b.year_month,
         a.vender_id,
         b.vender_id,
         a.vender_name,
         b.vender_name

#####qxf_user_retention_detail  查询sql

SELECT year_month,
       retention_year_month,
       vender_id,
       order_type,
       sale_type,
       retention_vender_id,
       retention_order_type,
       retention_sale_type,
       count(DISTINCT retention_webuser_id) AS user_cnt
FROM
  (SELECT DISTINCT substr(order_create_time,1,7) AS year_month,
                   vender_id,
                   order_type,
                   sale_type,
                   webuser_id     
   FROM dmall_order.wm_order
   WHERE dt >= '20170101'
     AND order_status = 1024) AS a
LEFT JOIN
  (SELECT DISTINCT substr(order_create_time,1,7) AS retention_year_month,
                   vender_id AS retention_vender_id,
                   order_type AS retention_order_type,
                   sale_type AS retention_sale_type,
                   webuser_id AS retention_webuser_id
   FROM dmall_order.wm_order
   WHERE dt >= '20170101'
     AND order_status = 1024) AS b 
    ON a.webuser_id = b.retention_webuser_id
WHERE a.year_month <= b.retention_year_month
GROUP BY year_month,
       retention_year_month,
       vender_id,
       order_type,
       sale_type,
       retention_vender_id,
       retention_order_type,
       retention_sale_type

#### 改，增加商家name，天津物美单独分出来
SELECT a.year_month year_month,
       b.year_month retention_year_month,
       a.vender_id vender_id,
       a.vender_name vender_name,
       a.order_type order_type,
       a.sale_type sale_type,
       b.vender_id retention_vender_id,
       b.vender_name retention_vender_name,
       b.order_type  retention_order_type,
       b.sale_type retention_sale_type,
       count(DISTINCT a.webuser_id) user_cnt
FROM
  (SELECT DISTINCT substr(a.order_complete_time,1,7) year_month,
                   CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN 1
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN 0
                       ELSE b.vender_id
                   END AS vender_id,
                   CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN '天津物美'
                       ELSE b.vender_name
                   END AS vender_name,
                   a.order_type,
                   a.sale_type,
                   a.webuser_id
   FROM dmall_order.wm_order a
   JOIN dm_data.dim_store b ON a.erp_store_id = b.store_id
   WHERE a.order_status = 1024
     AND a.dt >= '20161201'
     and a.order_complete_time >= '2017-01-01 00:00:00') a
JOIN
  (SELECT DISTINCT substr(a.order_complete_time,1,7) year_month,
                   CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN 1
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN 0
                       ELSE b.vender_id
                   END AS vender_id,
                   CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN '天津物美'
                       ELSE b.vender_name
                   END AS vender_name,
                   a.order_type, 
                   a.sale_type,
                   a.webuser_id
   FROM dmall_order.wm_order a
   JOIN dm_data.dim_store b ON a.erp_store_id = b.store_id
   WHERE a.order_status = 1024
    and a.dt >= '20161201'
     and a.order_complete_time >= '2017-01-01 00:00:00'
     ) b ON a.webuser_id = b.webuser_id
WHERE a.year_month <= b.year_month
GROUP BY a.year_month,
         b.year_month,
         a.vender_id,
         a.vender_name,
         a.order_type,
         a.sale_type,
         b.vender_id,
         b.vender_name,
         b.order_type,
         b.sale_type

# qxf_newuser_retention  改
SELECT a.year_month year_month,
       a.vender_id vender_id,
       a.vender_name vender_name,
       a.order_type order_type,
       a.sale_type sale_type,
       b.year_month retention_year_month,
       b.vender_id retention_vender_id,
       b.vender_name retention_vender_name,
       b.order_type retention_order_type,
       b.sale_type retention_sale_type,
       count(DISTINCT b.webuser_id) user_cnt
FROM
  (SELECT CASE
              WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN 1
              WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN 0
              ELSE b.vender_id
          END AS vender_id,
          CASE
              WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
              WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN '天津物美'
              ELSE b.vender_name
          END AS vender_name,
          a.order_type,
          a.sale_type,
          a.webuser_id,
          substr(min(a.order_complete_time),1,7) year_month
   FROM dmall_order.wm_order a
   JOIN dm_data.dim_store b ON a.erp_store_id = b.store_id
   WHERE a.dt >= '20150101'
     AND a.order_status = 1024
   GROUP BY CASE
              WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN 1
              WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN 0
              ELSE b.vender_id
          END,
             CASE
              WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
              WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN '天津物美'
              ELSE b.vender_name
          END,
            a.order_type,
            a.sale_type,
            a.webuser_id) a
LEFT JOIN
  (SELECT DISTINCT substr(a.order_complete_time,1,7) year_month,
                   CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN 1
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN 0
                       ELSE b.vender_id
                   END AS vender_id,
                   CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN '天津物美'
                       ELSE b.vender_name
                   END AS vender_name,
                   a.order_type,
                   a.sale_type,
                   a.webuser_id
   FROM dmall_order.wm_order a 
   JOIN dm_data.dim_store b ON a.erp_store_id = b.store_id
   WHERE a.dt >= '20150101'
     AND a.order_status = 1024 ) b ON a.webuser_id = b.webuser_id
GROUP BY a.year_month,
         a.vender_id,
         a.vender_name,
         a.order_type,
         a.sale_type,
         b.year_month,
         b.vender_id,
         b.vender_name,
         b.order_type,
         b.sale_type 


# qxf_user_day_retention
SELECT    a.order_create_date  order_create_date,
b.order_create_date retention_date,
a.vender_id,
a.order_type,
a.sale_type,
       b.vender_id retention_vender_id,
       b.order_type retention_order_type,
       b.sale_type retention_sale_type,
       count(distinct b.webuser_id ) user_cnt
FROM
  (SELECT DISTINCT to_date(order_create_time) order_create_date,
                   vender_id,
                   order_type,
                   sale_type,
                   webuser_id              
   FROM dmall_order.wm_order
   WHERE order_status = 1024
     AND dt >= regexp_replace(date_sub(CURRENT_DATE,90),'-','')) a
 left JOIN
  (SELECT DISTINCT to_date(order_create_time) order_create_date,
                   vender_id,
                   order_type,
                   sale_type,
                   webuser_id              
   FROM dmall_order.wm_order
   WHERE order_status = 1024
     AND dt >= regexp_replace(date_sub(CURRENT_DATE,90),'-','')) b 
     ON a.webuser_id = b.webuser_id
     where  a.order_create_date <= b.order_create_date
     group by  a.order_create_date ,b.order_create_date,
a.vender_id,
a.order_type,
a.sale_type,
       b.vender_id ,
       b.order_type,
       b.sale_type 

#改
SELECT a.order_complete_date order_create_date,
       b.order_complete_date retention_date,
       a.vender_id,
       a.vender_name,
       a.order_type,
       a.sale_type,
       b.vender_id retention_vender_id,
       b.vender_name retention_vender_name,
       b.order_type retention_order_type,
       b.sale_type retention_sale_type,
       count(DISTINCT b.webuser_id) user_cnt
FROM
  (SELECT DISTINCT to_date(order_complete_time) order_complete_date,
                  CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN 1
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN 0
                       ELSE b.vender_id
                   END AS vender_id,
                   CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN '天津物美'
                       ELSE b.vender_name
                   END AS vender_name,
                   order_type,
                   sale_type,
                   webuser_id
   FROM dmall_order.wm_order a 
   join dm_data.dim_store b
   on a.erp_store_id = b.store_id
   WHERE a.order_status = 1024
     AND a.dt >= regexp_replace(date_sub(CURRENT_DATE,100),'-','')
     and a.order_complete_time >= date_sub(CURRENT_DATE,90)) a
LEFT JOIN
  (SELECT DISTINCT to_date(order_complete_time) order_complete_date,
                  CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN 1
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN 0
                       ELSE b.vender_id
                   END AS vender_id,
                   CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN '天津物美'
                       ELSE b.vender_name
                   END AS vender_name,
                   order_type,
                   sale_type,
                   webuser_id
   FROM dmall_order.wm_order a 
   join dm_data.dim_store b
   on a.erp_store_id = b.store_id
   WHERE a.order_status = 1024
     AND a.dt >= regexp_replace(date_sub(CURRENT_DATE,100),'-','')
     and a.order_complete_time >= date_sub(CURRENT_DATE,90)) b ON a.webuser_id = b.webuser_id
WHERE a.order_complete_date <= b.order_complete_date
GROUP BY a.order_complete_date,
         b.order_complete_date,
         a.vender_id,
         a.vender_name,
         a.order_type,
         a.sale_type,
         b.vender_id,
         b.vender_name,
         b.order_type,
         b.sale_type

#qxf_newuser_day_retention（错了）
SELECT a.month_day year_month_day,
        a.vender_id vender_id,
       a.order_type order_type,
       a.sale_type sale_type,
       b.month_day retention_year_month_day,
       b.vender_id retention_vender_id, 
       b.order_type retention_order_type,
       b.sale_type retention_sale_type,
       count( distinct b.webuser_id) user_cnt
FROM (
     SELECT   vender_id,
                order_type,
                sale_type,
                webuser_id,
                substr(min(order_create_time),0,10)  month_day
                       FROM dmall_order.wm_order
                       WHERE dt >= regexp_replace(date_sub(CURRENT_DATE,90),'-','')
                         AND order_status = 1024
                       GROUP BY vender_id, order_type, sale_type, webuser_id
                      ) a
 left JOIN
  ( SELECT DISTINCT substr(order_create_time,1,10) month_day,
                    vender_id,
                    order_type,
                    sale_type,
                    webuser_id
   FROM dmall_order.wm_order
   WHERE dt >= regexp_replace(date_sub(CURRENT_DATE,90),'-','')
     AND order_status = 1024 ) b
           on a.webuser_id = b.webuser_id
    group by a.month_day ,
        a.vender_id ,
       a.order_type ,
       a.sale_type ,
       b.month_day ,
       b.vender_id , 
       b.order_type ,
       b.sale_type  
#改
SELECT a.month_day year_month_day,
       a.vender_id vender_id,
       a.vender_name vender_name,
       a.order_type order_type,
       a.sale_type sale_type,
       b.month_day retention_year_month_day,
       b.vender_id retention_vender_id,
       b.vender_name retention_vender_name,
       b.order_type retention_order_type,
       b.sale_type retention_sale_type,
       count(DISTINCT b.webuser_id) user_cnt
FROM
  (SELECT CASE
              WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN 1
              WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN 0
              ELSE b.vender_id
          END AS vender_id,
          CASE
              WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
              WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN '天津物美'
              ELSE b.vender_name
          END AS vender_name,
          a.order_type,
          a.sale_type,
          a.webuser_id,
          to_date(min(a.order_complete_time)) month_day
   FROM dmall_order.wm_order a
   JOIN dm_data.dim_store b ON a.erp_store_id = b.store_id
   WHERE a.dt >= '20150101'
     AND a.order_status = 1024
   GROUP BY CASE
                WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN 1
                WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN 0
                ELSE b.vender_id
            END,
            CASE
                WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
                WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN '天津物美'
                ELSE b.vender_name
            END,
            order_type,
            sale_type,
            webuser_id
   HAVING to_date(min(a.order_complete_time)) >= date_sub(CURRENT_DATE,90)) a
LEFT JOIN
  (SELECT DISTINCT substr(a.order_complete_time,1,10) month_day,
                   CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN 1
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN 0
                       ELSE b.vender_id
                   END AS vender_id,
                   CASE
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
                       WHEN b.vender_id = 1 AND b.store_provincial_level_name = '天津市' THEN '天津物美'
                       ELSE b.vender_name
                   END AS vender_name,
                   a.order_type,
                   a.sale_type,
                   a.webuser_id
   FROM dmall_order.wm_order a
   JOIN dm_data.dim_store  b ON a.erp_store_id = b.store_id
   WHERE a.dt >= regexp_replace(date_sub(CURRENT_DATE,120),'-','')
     AND a.order_complete_time >= date_sub(CURRENT_DATE,90)
     AND a.order_status = 1024 ) b ON a.webuser_id = b.webuser_id
GROUP BY a.month_day,
         a.vender_id,
         a.vender_name,
         a.order_type,
         a.sale_type,
         b.month_day,
         b.vender_id,
         b.vender_name,
         b.order_type,
         b.sale_type

# 不分商家的线上单用户复购

SELECT a.year_month year_month,
       b.year_month retention_year_month,
       count(DISTINCT b.webuser_id) AS user_cnt
FROM
  (SELECT DISTINCT substr(order_complete_time,1,7) AS year_month,
                   webuser_id     
   FROM dmall_order.wm_order
   WHERE dt >= '20150101'
   and order_type = 1
   and sale_type in (1,2)
   and order_complete_time BETWEEN '2017-01-01 00:00:00' and '2017-12-31 23:59:59'
   and order_status = 1024
   ) AS a
LEFT JOIN
  (SELECT DISTINCT substr(order_complete_time,1,7) AS year_month,
                   webuser_id     
   FROM dmall_order.wm_order
   WHERE dt >= '20150101'
   and order_type = 1
   and sale_type in (1,2)
   and order_complete_time BETWEEN '2017-01-01 00:00:00' and '2017-12-31 23:59:59'
   and order_status = 1024) AS b 
    ON a.webuser_id = b.webuser_id
WHERE a.year_month <= b.year_month
GROUP BY a.year_month ,
       b.year_month




#线上单新用户留存
SELECT a.year_month year_month,
       b.year_month retention_year_month,
       count(DISTINCT b.webuser_id) user_cnt
FROM
  (SELECT webuser_id,
          substr(min(order_complete_time),0,7) year_month
   FROM dmall_order.wm_order
   WHERE dt >= '20150101'
     AND order_type = 1
     AND sale_type IN (1,2)
     AND order_status = 1024
   GROUP BY webuser_id
   HAVING min(order_complete_time) BETWEEN "2017-01-01 00:00:00" AND "2017-12-31 23:59:59") a
left JOIN
  (SELECT DISTINCT substr(order_complete_time,1,7) AS year_month,
                   webuser_id     
   FROM dmall_order.wm_order
   WHERE dt >= '20150101'
   and order_type = 1
   and sale_type in (1,2)
   and order_complete_time BETWEEN '2017-01-01 00:00:00' and '2017-12-31 23:59:59'
   and order_status = 1024 ) b 
   ON a.webuser_id = b.webuser_id
   where a.year_month <= b.year_month
GROUP BY a.year_month,
         b.year_month



qxf_user_lost 
INSERT OVERWRITE TABLE tmp.qxf_user_lost

SELECT a.year_month year_month,
       a.vender_id vender_id,
       a.vender_name vender_name,
       a.order_type order_type,
       a.sale_type sale_type,
       b.year_month lost_year_month,
       b.vender_id lost_vender_id,
       b.vender_name lost_vender_name,
       count(DISTINCT a.webuser_id) user_cnt
FROM
  (SELECT  substr(a.order_complete_time,1,7) year_month,
                   CASE
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name <> '天津市' THEN 1
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name = '天津市' THEN 85
                       ELSE b.vender_id
                   END AS vender_id,
                   CASE
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name = '天津市' THEN '天津物美'
                       ELSE b.vender_name
                   END AS vender_name,
                   a.order_type,
                   a.sale_type,
                   a.webuser_id
   FROM dmall_order.wm_order a
   JOIN dm_data.dim_store b ON a.erp_store_id = b.store_id
   WHERE a.order_status = 1024
     AND a.dt >= '20161201'
     AND a.order_complete_time >= '2017-01-01 00:00:00'
     group by substr(a.order_complete_time,1,7),
                   CASE
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name <> '天津市' THEN 1
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name = '天津市' THEN 85
                       ELSE b.vender_id
                   END,
                   CASE
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name = '天津市' THEN '天津物美'
                       ELSE b.vender_name
                   END,
                   a.order_type,
                   a.sale_type,
                   a.webuser_id) a
JOIN
  (SELECT  substr(a.order_complete_time,1,7) year_month,
                   CASE
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name <> '天津市' THEN 1
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name = '天津市' THEN 85
                       ELSE b.vender_id
                   END AS vender_id,
                   CASE
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name = '天津市' THEN '天津物美'
                       ELSE b.vender_name
                   END AS vender_name,
                   a.webuser_id
   FROM dmall_order.wm_order a
   JOIN dm_data.dim_store b ON a.erp_store_id = b.store_id
   WHERE a.order_status = 1024
     AND a.dt >= '20161201'
     AND a.order_complete_time >= '2017-01-01 00:00:00' 
     group by substr(a.order_complete_time,1,7),
                   CASE
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name <> '天津市' THEN 1
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name = '天津市' THEN 85
                       ELSE b.vender_id
                   END,
                   CASE
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name <> '天津市' THEN '北京物美（剔除天津）'
                       WHEN b.vender_id = 1
                            AND b.store_provincial_level_name = '天津市' THEN '天津物美'
                       ELSE b.vender_name
                   END ,
                   a.webuser_id) b ON a.webuser_id = b.webuser_id
WHERE a.year_month <= b.year_month
GROUP BY a.year_month,
         b.year_month,
         a.vender_id,
         a.vender_name,
         a.order_type,
         a.sale_type,
         b.vender_id,
         b.vender_name


#对外复购数据，多点用户复购
SELECT a.year_month year_month,
       b.year_month retention_year_month,
       count(DISTINCT b.webuser_id) AS user_cnt
FROM
  (SELECT DISTINCT substr(order_create_time,1,7) AS year_month,
                   webuser_id     
   FROM dmall_order.wm_order
   WHERE dt >= '20150101'
   and order_create_time BETWEEN '2016-01-01 00:00:00' and '2018-07-31 23:59:59'
   and order_status = 1024
   ) AS a
LEFT JOIN
  (SELECT DISTINCT substr(order_create_time,1,7) AS year_month,
                   webuser_id     
   FROM dmall_order.wm_order
   WHERE dt >= '20150101'
   and order_create_time BETWEEN '2016-01-01 00:00:00' and '2018-07-31 23:59:59'
   and order_status = 1024) AS b 
    ON a.webuser_id = b.webuser_id
WHERE a.year_month <= b.year_month
GROUP BY a.year_month,
       b.year_month

##多点新用户复购