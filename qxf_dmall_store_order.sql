旧表
INSERT OVERWRITE table bigdata_bi.qxf_dmall_store_order
SELECT aa.order_complete_date order_complete_date ,
       aa.vender_id vender_id ,
       aa.vender_name vender_name,
       aa.area_name area_name,
       aa.store_sap_id store_sap_id,
       aa.store_name store_name,
       aa.store_type store_type,
       aa.longitude longitude,
       aa.latitude latitude,
       aa.order_type order_type ,
       aa.sale_type sale_type ,
       aa.sourceTag sourceTag ,
       aa.online_payment_type online_payment_type ,
       aa.shipment_type shipment_type ,
       aa.order_cnt order_cnt ,
       aa.gmv GMV,
       aa.promotion_price promotion_price ,
       aa.true_gmv TRUE_GMV,
       aa.use_CouponAmount use_CouponAmount,
       aa.freightCouponAmount freightCouponAmount,
       aa.use_Coupon_cnt use_Coupon_cnt,
       aa.freight_coupon_cnt freight_coupon_cnt ,
       bb.total_order_cnt total_order_cnt,
       bb.total_gmv TOTAL_GMV,
       cc.misc_fee misc_fee,
       cc.misc_orders misc_orders
FROM
  (SELECT to_date(a.order_complete_time) order_complete_date,
          a.vender_id vender_id,
          a.vender_name vender_name,
          b.store_management_area_name area_name,
          a.external_store_code store_sap_id,
          b.store_name store_name,
          b.store_type store_type,
          c.longitude longitude,
          c.latitude latitude,
          a.order_type order_type,
          a.sale_type sale_type,
          get_json_object(a.custom_tag,'$.sourceTag') sourceTag,
          a.online_payment_type online_payment_type,
          a.shipment_type shipment_type,
          count(DISTINCT coalesce(a.parent_id,a.id)) order_cnt,
          sum(a.ware_total_price)/100 gmv,
          sum(a.promotion_price)/100 promotion_price,
          sum(a.ware_total_price)/100-sum(a.promotion_price)/100 true_gmv,
         sum(a.use_Coupon)/100 use_CouponAmount,
         sum(get_json_object(a.properties,"$.freightCouponAmount"))/100 freightCouponAmount,
          count( distinct CASE
                  WHEN a.use_Coupon > 0 THEN  coalesce(a.parent_id,a.id)
                  ELSE null
              END) use_Coupon_cnt,
          count( distinct CASE
                  WHEN get_json_object(a.properties,"$.freightCouponAmount") > 0 THEN coalesce(a.parent_id,a.id)
                  ELSE null 
              END) freight_coupon_cnt
   FROM dmall_order.wm_order a
   JOIN dm_data.dim_store b ON a.erp_store_id = b.store_id  AND b.store_test_flag != 2
   join dmall_oop.store c on a.erp_store_id = c.id 
   WHERE a.trade_type <> 15
     AND a.order_status = 1024
     AND a.dt >= regexp_replace(date_sub(CURRENT_DATE,376),'-','')
     and a.order_complete_time >= date_sub(CURRENT_DATE,366)
   GROUP BY to_date(a.order_complete_time),
            a.vender_id,
            a.vender_name,
            b.store_management_area_name,
            a.external_store_code,
            b.store_name,
            b.store_type,
            c.longitude,
            c.latitude,
            a.order_type,
            a.sale_type,
            get_json_object(a.custom_tag,'$.sourceTag'),
            a.online_payment_type,
            a.shipment_type) aa
LEFT JOIN
  (select a.order_date,
       a.vender_id,
       a.sap_id,
       sum(order_cnt) total_order_cnt,
       sum(gmv) total_gmv
from 
(SELECT to_date(order_complete_time) order_date,
       vender_id,
       store_sap_id sap_id,
       count(1) AS order_cnt,
       sum(order_gmv/100) gmv
FROM dwd_data.dwd_order_offline
WHERE dt >= regexp_replace(date_sub(CURRENT_DATE,376),'-','')
GROUP BY to_date(order_complete_time),
       vender_id,
       store_sap_id

union all

SELECT to_date(order_complete_time) order_date,
       vender_id,
       external_store_code sap_id,
       count(DISTINCT coalesce(parent_id,id))  AS order_cnt,
       sum(ware_total_price - promotion_price)/100   as gmv
   FROM dmall_order.wm_order
   WHERE order_type <> 3
     AND order_status = 1024
     AND dt >= regexp_replace(date_sub(CURRENT_DATE,376),'-','')
    GROUP BY to_date(order_complete_time),
       vender_id,
       external_store_code
       ) a
GROUP by a.order_date,
       a.vender_id,
       a.sap_id
) bb ON aa.order_complete_date = bb.order_date
AND aa.vender_id = bb.vender_id
AND aa.store_sap_id = bb.sap_id
left join 
(SELECT to_date(a.trade_time) trade_date,
       c.id vender_id,
       a.store_id store_sap_id,
       sum(b.trade_fee)/100 AS misc_fee,
       count(DISTINCT order_no) AS misc_orders
FROM dmall_pay_misc.pay_trade_record a
join dmall_pay_misc.trade_record_detail b
on a.trade_no = b.trade_no
join dmall_oop.vender c
on a.vender_id = c.vender_sap_id
where  ((a.domain_version = 0 and a.pay_way = '-99') or a.pay_way = '888')
and a.dt >=regexp_replace(date_sub(CURRENT_DATE,366),'-','')
and b.dt >= regexp_replace(date_sub(CURRENT_DATE,366),'-','')
and COALESCE(b.trade_status,1) != -1
and b.trade_type = 1 
and a.pay_scan_code = 1   
GROUP BY to_date(a.trade_time),
       c.id, a.store_id) cc 
on aa.order_complete_date = cc.trade_date
AND aa.vender_id = cc.vender_id
AND aa.store_sap_id = cc.store_sap_id

修改后，目前使用中
INSERT overwrite table bigdata_bi.qxf_dmall_store_order

SELECT aa.order_complete_date order_complete_date ,
       aa.vender_id vender_id ,
       aa.vender_name vender_name,
       aa.area_name area_name,
       aa.store_sap_id store_sap_id,
       aa.store_name store_name,
       aa.store_type store_type,
       aa.longitude longitude,
       aa.latitude latitude,
       aa.order_type order_type ,
       aa.sale_type sale_type ,
       aa.sourceTag sourceTag ,
       aa.online_payment_type online_payment_type ,
       aa.shipment_type shipment_type ,
       aa.order_cnt order_cnt ,
       aa.gmv GMV,
       aa.promotion_price promotion_price ,
       aa.true_gmv TRUE_GMV,
       aa.use_CouponAmount use_CouponAmount,
       aa.freightCouponAmount freightCouponAmount,
       aa.use_Coupon_cnt use_Coupon_cnt,
       aa.freight_coupon_cnt freight_coupon_cnt ,
       bb.total_order_cnt total_order_cnt,
       bb.total_gmv TOTAL_GMV,
       cc.misc_fee misc_fee,
       cc.misc_orders misc_orders
FROM
  (SELECT a.order_complete_date order_complete_date,
       a.vender_id vender_id,
       a.vender_name vender_name,
       b.store_management_area_name area_name,
       a.store_sap_id store_sap_id,
       b.store_name store_name,
       b.store_type store_type,
       c.longitude longitude,
       c.latitude latitude,
       a.order_type order_type,
       a.sale_type sale_type,
       a.sourceTag sourceTag,
       a.online_payment_type online_payment_type,
       a.shipment_type shipment_type,
       count(DISTINCT parent_id) order_cnt,
       sum(gmv) gmv,
       sum(promotion_price) promotion_price,
       sum(true_gmv) true_gmv,
       sum(use_CouponAmount) use_CouponAmount,
       sum(freightCouponAmount) freightCouponAmount,
       sum(use_Coupon_cnt) use_Coupon_cnt,
       sum(freight_coupon_cnt) freight_coupon_cnt
FROM
  (SELECT coalesce(a.parent_id,a.id) parent_id,
          max(to_date(a.order_complete_time)) order_complete_date,
          a.vender_id vender_id,
          a.vender_name vender_name,
          a.erp_store_id erp_store_id,
          a.external_store_code store_sap_id,
          a.order_type order_type,
          a.sale_type sale_type,
          get_json_object(a.custom_tag,'$.sourceTag') sourceTag,
          a.online_payment_type online_payment_type,
          a.shipment_type shipment_type,
          sum(a.ware_total_price)/100 gmv,
          sum(a.promotion_price)/100 promotion_price,
          sum(a.ware_total_price)/100-sum(a.promotion_price)/100 true_gmv,
          sum(a.use_Coupon)/100 use_CouponAmount,
          sum(get_json_object(a.properties,"$.freightCouponAmount"))/100 freightCouponAmount,
          count(DISTINCT CASE
                             WHEN a.use_Coupon > 0 THEN coalesce(a.parent_id,a.id)
                             ELSE NULL
                         END) use_Coupon_cnt,
          count(DISTINCT CASE
                             WHEN get_json_object(a.properties,"$.freightCouponAmount") > 0 THEN coalesce(a.parent_id,a.id)
                             ELSE NULL
                         END) freight_coupon_cnt
   FROM dmall_order.wm_order a
   WHERE a.trade_type <> 15
     AND a.order_status = 1024
     AND a.dt >= regexp_replace(date_sub(CURRENT_DATE,376),'-','')
     AND a.order_complete_time >= date_sub(CURRENT_DATE,366)
     and to_date(a.order_complete_time) < current_date()
   GROUP BY coalesce(a.parent_id,a.id),
            a.vender_id,
            a.vender_name,
            a.external_store_code,
            a.erp_store_id,
            a.order_type,
            a.sale_type,
            get_json_object(a.custom_tag,'$.sourceTag'),
            a.online_payment_type,
            a.shipment_type) a
JOIN dm_data.dim_store b ON a.erp_store_id = b.store_id
AND b.store_test_flag != 2
JOIN dmall_oop.store c ON a.erp_store_id = c.id
GROUP BY a.order_complete_date,
         a.vender_id,
         a.vender_name,
         b.store_management_area_name,
         a.store_sap_id,
         b.store_name,
         b.store_type,
         c.longitude,
         c.latitude,
         a.order_type,
         a.sale_type,
         a.sourceTag,
         a.online_payment_type,
         a.shipment_type) aa
LEFT JOIN
  (select a.order_date,
       a.vender_id,
       a.sap_id,
       sum(order_cnt) total_order_cnt,
       sum(gmv) total_gmv
from 
(SELECT to_date(a.order_complete_time) order_date,
       CASE
           WHEN b.store_provincial_level_name = '天津市'
                AND b.vender_id = 1 THEN 85
           ELSE a.vender_id
       END AS vender_id,
       a.store_sap_id sap_id,
       count(1) AS order_cnt,
       sum(a.order_gmv/100) gmv
FROM dwd_data.dwd_order_offline a
JOIN dm_data.dim_store b ON a.store_id = b.store_id
WHERE a.dt >= regexp_replace(date_sub(CURRENT_DATE,376),'-','')
GROUP BY to_date(a.order_complete_time),
         CASE
           WHEN b.store_provincial_level_name = '天津市'
                AND b.vender_id = 1 THEN 85
           ELSE a.vender_id
       END,
         a.store_sap_id

union all

SELECT a.order_date order_date,
a.vender_id vender_id,
a.sap_id sap_id,
count(DISTINCT parent_id) order_cnt,
sum(gmv) gmv
from 
(SELECT coalesce(parent_id,id) parent_id,
       max(to_date(order_complete_time)) order_date,
       vender_id,
       external_store_code sap_id,
       sum(ware_total_price - promotion_price)/100 AS gmv
FROM dmall_order.wm_order
WHERE order_type <> 3
  AND order_status = 1024
  AND dt >= regexp_replace(date_sub(CURRENT_DATE,376),'-','')
GROUP BY coalesce(parent_id,id),
         vender_id,
         external_store_code) a
GROUP BY a.order_date,
a.vender_id,
a.sap_id) a
GROUP by a.order_date,
       a.vender_id,
       a.sap_id
) bb ON aa.order_complete_date = bb.order_date
AND aa.vender_id = bb.vender_id
AND aa.store_sap_id = bb.sap_id
left join 
(SELECT to_date(a.trade_time) trade_date,
       c.id vender_id,
       a.store_id store_sap_id,
       sum(b.trade_fee)/100 AS misc_fee,
       count(DISTINCT order_no) AS misc_orders
FROM dmall_pay_misc.pay_trade_record a
join dmall_pay_misc.trade_record_detail b
on a.trade_no = b.trade_no
join dmall_oop.vender c
on a.vender_id = c.vender_sap_id
where  ((a.domain_version = 0 and a.pay_way = '-99') or a.pay_way = '888')
and a.dt >=regexp_replace(date_sub(CURRENT_DATE,376),'-','')
and b.dt >= regexp_replace(date_sub(CURRENT_DATE,376),'-','')
and COALESCE(b.trade_status,1) != -1
and b.trade_type = 1 
and a.pay_scan_code = 1   
GROUP BY to_date(a.trade_time),
       c.id, a.store_id) cc 
on aa.order_complete_date = cc.trade_date
AND aa.vender_id = cc.vender_id
AND aa.store_sap_id = cc.store_sap_id