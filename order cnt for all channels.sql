SELECT to_date(a.order_complete_time) complete_date,
       a.vender_name AS`商家`,
       a.external_store_code AS`店号`,
       a.shop_name AS`门店`,
       count(DISTINCT if(a.sale_type = 1
                         AND a.order_type = 1, if(a.parent_id IS NULL, a.id, a.parent_id),NULL)) AS`020单量`,
       sum(if(a.sale_type = 1
              AND a.order_type = 1, a.total_price-a.promotion_price,NULL))/100 AS`020gmv`,
       count(DISTINCT if(a.sale_type = 2, if(a.parent_id IS NULL, a.id, a.parent_id),NULL)) AS`精选单量`,
       sum(if(a.sale_type = 2, a.total_price-a.promotion_price,NULL))/100 AS`精选gmv`,
       count(DISTINCT if(a.sale_type IN(1,2)
                         AND a.order_type = 1, if(a.parent_id IS NULL, a.id, a.parent_id),NULL)) AS`020+精选单量`,
       sum(if(a.sale_type IN(1,2)
              AND a.order_type = 1, a.total_price-a.promotion_price,NULL))/100 AS `020+精选gmv`,
       count(DISTINCT if(a.sale_type = 18, if(a.parent_id IS NULL, a.id, a.parent_id),NULL)) AS`智能购单量`,
       sum(if(a.sale_type = 18
              AND a.order_type = 1, a.total_price-a.promotion_price,NULL))/100 AS`智能购 gmv`,
       count(DISTINCT if(a.sale_type = 18
                         AND get_json_object (a.custom_tag, '$.sourceTag') IS NULL,if(a.parent_id IS NULL, a.id, a.parent_id),NULL)) AS`普通自由购`,
       sum(if(a.sale_type = 18
              AND get_json_object (a.custom_tag, '$.sourceTag') IS NULL, a.total_price-a.promotion_price,NULL))/100 AS`普通自由购gmv`,
       count(DISTINCT if(a.sale_type = 18
                         AND get_json_object (a.custom_tag, '$.sourceTag')=2,if(a.parent_id IS NULL, a.id, a.parent_id),NULL)) AS `多点自助收银`,
       sum(if(a.sale_type = 18
              AND get_json_object (a.custom_tag, '$.sourceTag')=2, a.total_price-a.promotion_price,NULL))/100 AS`多点自助收银gmv`,
       count(DISTINCT if(a.sale_type = 18
                         AND get_json_object (a.custom_tag, '$.sourceTag')=1,if(a.parent_id IS NULL, a.id, a.parent_id),NULL)) AS `智能购物车`,
       sum(if(a.sale_type = 18
              AND get_json_object (a.custom_tag, '$.sourceTag')=1, a.total_price-a.promotion_price,NULL))/100 AS`智能购物车gmv`,
       count(DISTINCT if(a.sale_type = 18
                         AND get_json_object (a.custom_tag, '$.sourceTag')=3,if(a.parent_id IS NULL, a.id, a.parent_id),NULL)) AS `物美自助收银`,
       sum(if(a.sale_type = 18
              AND get_json_object (a.custom_tag, '$.sourceTag')=3, a.total_price-a.promotion_price,NULL))/100 AS`物美自助收银gmv`,
       count(DISTINCT if(a.sale_type = 18
                         AND get_json_object (a.custom_tag, '$.sourceTag')=4,if(a.parent_id IS NULL, a.id, a.parent_id),NULL)) AS `无人便利`,
       sum(if(a.sale_type = 18
              AND get_json_object (a.custom_tag, '$.sourceTag')=4, a.total_price-a.promotion_price,NULL))/100 AS`无人便利gmv`
FROM dmall_order.wm_order a
WHERE a.dt>='2018-04-01'
  AND a.order_complete_time>='2018-04-08 00:00:00'
  AND a.order_complete_time<='2018-04-08 23:59:59'
  AND a.order_status!=128
GROUP BY a.vender_name,
         a.shop_name,
         a.external_store_code,
         to_date(a.order_complete_time)
LIMIT 10000000