SELECT b.store_id `门店id`,
       b.store_name `门店名称`,
       b.pick_last_user_id `拣货人员id`,
       c.user_namem `拣货人员姓名`,
       count(a.bar_code) `拣货sku数`,
       count(CASE
                 WHEN a.source =2 THEN a.bar_code
                 ELSE NULL
             END) `手输sku数`,
        round(count(CASE
                 WHEN a.source =2 THEN a.bar_code
                 ELSE NULL
             END)/ count(a.bar_code),2) `手输占比`
FROM dmall_wms.wms_pos_recording_item a
LEFT JOIN dwd_data.dwd_order_online_view b ON a.order_id = b.order_id 
and  b.dt >= regexp_replace(date_sub(CURRENT_DATE,5),'-','')
LEFT JOIN dm_data.dim_erp_user c 
on b.pick_last_user_id = c.user_id
where  b.vender_id = 2
AND to_date(b.order_complete_time) = current_date()
AND a.dt >= regexp_replace(date_sub(CURRENT_DATE,5),'-','')
GROUP BY b.store_id,
         b.store_name,
         b.pick_last_user_id,c.user_name


SELECT b.store_id `门店id`,
       b.store_name `门店名称`,
       b.pick_last_user_id `拣货人员id`,
       c.user_name `拣货人员姓名`,
       a.bar_code `国条`,
       a.matnr `物料编码`,
       d.sku_id `sku_id`,
       d.ware_name `商品名称`
FROM dmall_wms.wms_pos_recording_item a
LEFT JOIN dwd_data.dwd_order_online_view b ON a.order_id = b.order_id 
and  b.dt >= regexp_replace(date_sub(CURRENT_DATE,5),'-','')
LEFT JOIN dm_data.dim_erp_user c 
on b.pick_last_user_id = c.user_id
left join dm_data.dim_ware d
on a.matnr = d.matnr and d.vender_id = 2
where  b.vender_id = 2
and a.source = 3
AND to_date(b.order_complete_time) = current_date()
AND a.dt >= regexp_replace(date_sub(CURRENT_DATE,5),'-','')