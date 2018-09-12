SELECT coalesce(a.parent_id,a.id) parent_id,
       a.webuser_id webuser_id,
       a.order_status order_status,
       a.order_create_time order_create_time,
       a.order_complete_time order_complete_time,
       a.shop_id shop_id,
       a.shop_name shop_name,
       b.matnr matnr,
       b.sku_id sku_id,
       b.ware_name ware_name,
       b.origin_ware_num ware_num,
       b.ware_price/100 ware_price,
       b.promotion_price/100 promotion_price,
       bb.back_price back_price,
       b.promotion_price/100 - if(bb.back_price IS NULL,0,back_price) true_promotion_price,
       b.coupon_amount/100 coupon_amount,
       c.code coupon_code,
       d.coupon_apply_id coupon_apply_id,
       c.value/100 value,
       c.quota/100 coupon_quota,
       v.name name,
       e.payer_type,
       e.payer_id payer_id,
       e.payer_name payer_name,
       e.payer_percent,
       v.proposer_name proposer_name
FROM dmall_order.wm_order a
JOIN dmall_wms.wms_order_ware b ON a.id = b.order_id
JOIN dmall_coupon.coup_coupon d ON a.use_coupon_id = d.code
JOIN dmall_coupon.coup_coupon_apply c ON d.coupon_apply_id=c.id
JOIN dmall_coupon.coup_activity v ON c.activity_code = v.code
JOIN dmall_coupon.coup_activity_expense_rule e ON v.id = e.activity_id
LEFT JOIN
  (SELECT order_id,
          sku_id,
          sum(back_price)/100 back_price
   FROM dmall_wms.wms_back_price
   WHERE yn = 1
     AND created >= date_sub(CURRENT_DATE,35)
   GROUP BY order_id,
            sku_id) bb ON a.id = bb.order_id
AND b.sku_id = bb.sku_id
WHERE order_type = 1
  AND sale_type IN (1, 2)
  AND a.dt>=regexp_replace(date_sub(CURRENT_DATE,30),'-','')
  AND b.dt>=regexp_replace(date_sub(CURRENT_DATE,30),'-','')
  AND d.dt>=regexp_replace(date_sub(CURRENT_DATE,60),'-','')
  AND b.yn=1
  and (e.payer_type in (2,3) 
  or (e.payer_type = 1 and e.payer_name in ('多点/华北线上运营中心/华北采销部','多点/华东线上运营中心/商品支持部','多点/华东线上运营中心/采销支持部')))