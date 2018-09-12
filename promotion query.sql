SELECT a.order_create_time `下单时间`,
       a.order_complete_time,
       a.shop_id,
       a.shop_name,
       a.id,
       a.order_status,
       w.matnr,
       w.sku_id,
       w.ware_name,
       w.ware_price/100,
       w.ware_num,
       split(w.promotion_price_list,','),
       split(w.promotion_id,',')
FROM dmall_order.wm_order a
JOIN dmall_order.wm_order_ware w ON a.id = w.order_id
WHERE w.sku_id IN ()
  AND a.dt>='20170915'
  AND w.dt>='20170915'
  AND a.vender_id = 2
  AND a.order_type = 1
  AND a.sale_type = 1
  AND a.trade_type IN (1,2)
  AND a.order_status <>128
  AND a.order_create_time BETWEEN '2017-09-18 00:00:00' AND '2017-09-18 23:59:59'