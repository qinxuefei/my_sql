SELECT to_date(order_create_time), a.id, d.name,c.value,c.quota
from 
(SELECT a.webuser_id, split(a.midfiled, ',')[1] as id, split(a.midfiled, ',')[0] as order_create_time
from 
(SELECT webuser_id, min(concat_ws(',',order_create_time, cast(coalesce(parent_id,id) as string )) )as midfiled
from dmall_order.wm_order
where vender_id = 2
and order_type = 1
and sale_type = 1
and order_status <> 128
and dt >= '20150101'
GROUP BY webuser_id) a
where split(a.midfiled, ',')[0] between '2018-04-16 00:00:00' and '2018-05-21 23:59:59') a
left join dmall_coupon.coup_coupon b 
on a.id = b.order_id and b.dt >= '20170101'
left join dmall_coupon.coup_coupon_apply c
on b.coupon_apply_id = c.id
left join dmall_coupon.coup_activity d
on c.activity_id  = d.id