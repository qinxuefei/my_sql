SELECT a.webuser_id, b.order_date,b.create_date, b.order_num
from 
(SELECT coalesce(parent_id, id), webuser_id, sum(use_coupon), sum(get_json_object(properties,'$.freightCouponAmount')) 
from dmall_order.wm_order
where vender_id = 2
and order_status <> 128
and order_type = 1
and sale_type = 1
and dt >= '20180422'
and order_create_time BETWEEN '2018-04-24 00:00:00' and '2018-04-24 23:59:59'
GROUP BY coalesce(parent_id, id), webuser_id
HAVING sum(use_coupon) =0
and  sum(get_json_object(properties,'$.freightCouponAmount')) = 0) a
join
(SELECT a.webuser_id webuser_id,
       to_date(max(a.order_create_time)) order_date,
       to_date(min(a.order_create_time)) create_date,
count(distinct coalesce(a.parent_id,a.id)) order_num
FROM dmall_order.wm_order a
WHERE a.vender_id=2
AND a.sale_type=1
AND a.order_type=1
AND a.trade_type IN (1,2)
AND a.order_status=1024
AND a.dt<=regexp_replace(date_sub(CURRENT_DATE,2),'-','')
GROUP BY a.webuser_id
) b
on a.webuser_id = b.webuser_id