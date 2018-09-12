SELECT default.wm_matnr(vender_id,matnr,b.dt) matnr,
b.sku_id,
       b.ware_name ware_name,
       sum(b.ware_num) ware_num,
       sum(b.ware_num * b.ware_price - b.promotion_price)/100 true_gmv
FROM dmall_order.wm_order a
JOIN dmall_order.wm_order_ware b ON a.id = b.order_id
WHERE
a.vender_id = 2 and order_type = 1 and a.sale_type =1
and a.trade_type = 1
and 
 a.dt>='20170801'
 and a.dt <= '20170831'
  AND b.dt>='20170801'
  and b.dt <= '20170831'
  AND a.order_status <>128
  AND b.yn=1
  and a.yn = 1
  GROUP BY default.wm_matnr(vender_id,matnr,b.dt), b.ware_name, b.sku_id