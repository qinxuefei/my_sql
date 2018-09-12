select slw.matnr
    ,dw.sku_id
    ,dw.ware_name
   ,count(distinct slw.shop_id) store_cnt
    from dmall_ware.sap_location_ware as slw
    join dm_data.dim_ware as dw
        on slw.ware_sku_id = dw.sku_id
        and dw.ware_tag = 1
    join dm_data.dim_store as s
        on slw.shop_id = s.store_id
        and s.vender_id = 1
        and s.store_test_flag <> 2
        and s.store_yn = 1
        and s.store_online_flag = 1
        and s.store_status = 1
        and s.store_open_flag = 1
    where slw.yn = 1
        and slw.publish_status = 1
        and slw.ware_status = 1
        and slw.sap_ware_status = 1
        group by slw.matnr
    ,dw.sku_id
    ,dw.ware_name