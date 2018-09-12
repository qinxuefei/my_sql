INSERT OVERWRITE table tmp.qxf_order_coupon_test

SELECT aa.parent_id parent_id,
       aa.vender_id  vender_id,
       aa.vender_name vender_name,
       aa.order_complete_time  order_complete_time,
       aa.order_create_time order_create_time,
       aa.sale_type sale_type,
       aa.webuser_id webuser_id,
       bb.freight_code freight_code,
       bb.use_coupon_id  use_coupon_id,
       bb.code coupon_code,
       bb.value value,
       bb.coupon_quota coupon_quota,
       bb.name name,
       bb.type_use_code type_use_code,
       bb.proposer_name proposer_name,
       bb.payer_type payer_type ,
       bb.ture_payer_id ture_payer_id,
       bb.ture_payer_name ture_payer_name,
       bb.payer_percent payer_percent,
       aa.gmv gmv,
       aa.freight_fee freight_fee,
       aa.use_coupon use_coupon
FROM
    (SELECT coalesce(a.parent_id,a.id) parent_id,
    a.vender_id vender_id,
    b.vender_name vender_name,
    max(to_date(a.order_complete_time)) order_complete_time,
    min(to_date(a.order_create_time)) order_create_time,
    a.sale_type sale_type,
    a.webuser_id webuser_id,
          sum(a.ware_total_Price-a.promotion_price)/100 gmv,
          sum(get_json_object(a.properties,"$.freightCouponAmount")/100) AS freight_fee,
          sum(a.use_Coupon/100) use_coupon
   FROM dmall_order.wm_order a
   join dmall_oop.vender b
   on a.vender_id = b.id   
   WHERE a.dt >= regexp_replace(date_sub(CURRENT_DATE,10),'-','')
   and to_date(a.order_create_time) >= date_sub(current_date(),7)
     AND a.order_type = 1
     AND a.order_status <>128
     AND a.sale_type IN (1,2)
     AND a.trade_type IN (1,2)
   GROUP BY coalesce(a.parent_id,a.id),
   a.vender_id,
   b.vender_name,
   a.sale_type,
   a.webuser_id) aa
LEFT JOIN
  (SELECT DISTINCT coalesce(o.parent_id,o.id) AS parent_id,
                   get_json_object(o.properties,"$.freightCouponCode") AS freight_code,
                   o.use_coupon_id use_coupon_id,
                   a.code code,
                   a.value/100 value,
                   a.quota/100 coupon_quota,
                   a.type_use_code type_use_code,
                   v.name name,
                   v.dept_name2 dept_name2,
         v.dept_name3 dept_name3,
         v.payer_id payer_id,
         v.payer_name payer_name,
         v.proposer_name proposer_name,
         r.payer_type payer_type ,
         r.payer_id ture_payer_id,
         r.payer_name ture_payer_name,
         r.payer_percent payer_percent
   FROM dmall_order.wm_order o
    JOIN dmall_coupon.coup_coupon c ON c.code = coalesce(o.use_coupon_id,get_json_object(o.properties,"$.freightCouponCode"))
   AND c.dt>='20170101'
   LEFT JOIN dmall_coupon.coup_coupon_apply a ON c.coupon_apply_id = a.id
   LEFT JOIN dmall_coupon.coup_activity v ON a.activity_code = v.code
   left join dmall_coupon.coup_activity_expense_rule r on v.id = r.activity_id 
   WHERE o.dt >= regexp_replace(date_sub(CURRENT_DATE,10),'-','')
     AND o.order_type =1
     AND o.order_status =1024
     AND o.sale_type IN (1,2)
     AND o.trade_type IN (1,2) ) bb ---拆单会产生两个子单一个有优惠券一个没有优惠券，因此不能用use_coupon_id grouy by 
    ON aa.parent_id = bb.parent_id