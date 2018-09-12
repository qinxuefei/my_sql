SELECT aa.complete_date `日期`,
       aa.vender_name `商家名称`,
       aa.area_name `管理区域`,
       aa.store_sap_id `店号`,
       aa.store_name `店名`,
       aa.full_time_ware_num `拣货完成品项数（全职）`,
       aa.full_time_picker_num `参与拣货人数（全职）`,
       aa.full_time_HE `拣货人效(全职)`,
       aa.part_time_ware_num `拣货完成品项数（兼职）`, 
       aa.part_time_picker_num `参与拣货人数（兼职）`,
       aa.part_time_HE `拣货人效(兼职)`,
       aa.total_ware_num `拣货完成品项数（整体）`, 
       aa.total_picker_num `参与拣货人数（整体）`,
       aa.total_HE `拣货人效(整体)`,
       bb.fulltime_delivery_order_num `配送单量（全职）`,
       bb.fulltime_delivery_id_num `配送人员数（全职）`,
       bb.fulltime_delivery_HE `配送人效（全职）`,
       bb.parttime_delivery_order_num `配送单量（兼职）`,
       bb.parttime_delivery_id_num `配送人员数（兼职）`,
       bb.parttime_delivery_HE `配送人效（兼职）`,
       bb.THE_THIRD_delivery_order_num `配送单量（三方）`,
       bb.the_third_delivery_id_num `配送人员数（三方）`,
       bb.third_delivery_HE `配送人效（三方）`,
       bb.total_delivery_order_cnt `配送单量（整体）`,
       bb.total_delivery_id_cnt `配送人员数（整体）`,
       bb.total_delivery_he `配送人效（整体）`
from 
        (SELECT to_date(a.order_complete_time) complete_date,
       c.vender_name vender_name,
       c.store_management_area_name area_name,
       c.store_sap_id store_sap_id,
       c.store_name store_name,
       sum(CASE  WHEN b.picker_full_time_status = 1 THEN a.order_sku_num  ELSE 0 END) full_time_ware_num,
       count(DISTINCT CASE WHEN b.picker_full_time_status = 1 THEN a.pick_last_user_id ELSE NULL END) full_time_picker_num,
       round(sum(CASE WHEN b.picker_full_time_status = 1 THEN a.order_sku_num ELSE 0 END)/ 
             count(DISTINCT CASE WHEN b.picker_full_time_status = 1 THEN a.pick_last_user_id ELSE NULL END),2) full_time_HE,
       sum(CASE WHEN b.picker_full_time_status = 0 THEN a.order_sku_num ELSE 0 END) part_time_ware_num,
       count(DISTINCT CASE WHEN b.picker_full_time_status = 0 THEN a.pick_last_user_id ELSE NULL END) part_time_picker_num,
       round(sum(CASE WHEN b.picker_full_time_status = 0 THEN a.order_sku_num ELSE 0 END)/
             count(DISTINCT CASE WHEN b.picker_full_time_status = 0 THEN a.pick_last_user_id ELSE NULL END),2) part_time_HE,
       sum(a.order_ware_num) total_ware_num,
       count(DISTINCT a.pick_last_user_id) total_picker_num,
       round(sum(a.order_ware_num)/ count(DISTINCT a.pick_last_user_id)) total_HE
FROM dwd_data.dwd_order_online_view a
LEFT JOIN dim_data.dim_erp_user b ON a.pick_last_user_id = b.user_id
LEFT JOIN dim_data.dim_store c ON a.store_id = c.store_id
AND c.store_test_flag != 2
WHERE a.order_complete_time BETWEEN '2018-08-17 18:00:00' AND '2018-08-19 23:59:59'
  AND a.pick_last_user_id IS NOT NULL
  AND a.dt >= '2018-08-15'
  AND c.vender_id IN (1,2)
GROUP BY to_date(a.order_complete_time),
         c.vender_name,
         c.store_management_area_name,
         c.store_sap_id,
         c.store_name
        ) aa
left join 
(SELECT to_date(a.order_complete_time) complete_date,
       s.vender_name vender_name,
       s.store_management_area_name area_name,
       s.store_sap_id store_sap_id,
       s.store_name store_name,
       count(DISTINCT CASE  WHEN u.delivery_full_time_status = 1 THEN coalesce(a.parent_id,a.order_id) ELSE NULL END) fulltime_delivery_order_num,
       count(DISTINCT CASE WHEN u.delivery_full_time_status = 1 THEN a.waybill_last_delivery_id ELSE NULL  END) fulltime_delivery_id_num,
       round(count(DISTINCT CASE WHEN u.delivery_full_time_status = 1 THEN coalesce(a.parent_id,a.order_id) ELSE NULL END)/
             count(DISTINCT CASE WHEN u.delivery_full_time_status = 1 THEN a.waybill_last_delivery_id ELSE NULL END),2) fulltime_delivery_HE,
       count(DISTINCT CASE WHEN u.delivery_full_time_status = 0 THEN coalesce(a.parent_id,a.order_id) ELSE NULL  END) parttime_delivery_order_num,
       count(DISTINCT CASE WHEN u.delivery_full_time_status = 0 THEN a.waybill_last_delivery_id ELSE NULL END) parttime_delivery_id_num,
       round(count(DISTINCT CASE WHEN u.delivery_full_time_status = 0 THEN coalesce(a.parent_id,a.order_id) ELSE NULL END)/
             count(DISTINCT CASE WHEN u.delivery_full_time_status = 0 THEN a.waybill_last_delivery_id ELSE NULL END),2) parttime_delivery_HE,
       count(DISTINCT CASE WHEN u.delivery_type = 2 THEN coalesce(a.parent_id,a.order_id) ELSE NULL END) THE_THIRD_delivery_order_num,
       count(DISTINCT CASE WHEN u.delivery_type = 2 THEN a.waybill_last_delivery_id ELSE NULL END) the_third_delivery_id_num,
       round(count(DISTINCT CASE WHEN u.delivery_type = 2 THEN coalesce(a.parent_id,a.order_id) ELSE NULL END)/ 
            count(DISTINCT CASE  WHEN u.delivery_type = 2 THEN a.waybill_last_delivery_id  ELSE NULL END),2) third_delivery_HE,
       count(DISTINCT coalesce(a.parent_id,a.order_id)) total_delivery_order_cnt,
       count(DISTINCT a.waybill_last_delivery_id) total_delivery_id_cnt,
       round(count(DISTINCT coalesce(a.parent_id,a.order_id))/count(DISTINCT a.waybill_last_delivery_id), 2) total_delivery_he
FROM dwd_data.dwd_order_online_view a
JOIN dim_data.dim_erp_user u ON a.waybill_last_delivery_id = u.user_id
INNER JOIN dim_data.dim_store s ON a.store_id = s.store_id
AND s.store_test_flag != 2
WHERE a.order_complete_time BETWEEN '2018-08-17 18:00:00' AND '2018-08-19 23:59:59'
  AND a.dt> '2018-08-15'
  AND a.waybill_last_delivery_id IS NOT NULL
  AND s.vender_id IN (1, 2)
GROUP BY to_date(a.order_complete_time),
         s.vender_name,
         s.store_management_area_name,
         s.store_sap_id,
         s.store_name) bb
on aa.complete_date = bb.complete_date
and aa.vender_name = bb.vender_name
    and aa.store_sap_id = bb.store_sap_id
    and aa.store_name = bb.store_name



