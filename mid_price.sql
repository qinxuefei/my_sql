SELECT w.first_category first_category,
       w.second_category second_category,
       w.third_category third_category,
       m.sku_id sku_id,
       d.sku matnr,
       n.title ware_name,
       d.promoprice promoprice,
       d.startdate start_date,
       d.enddate end_date,
       substr(d.lsdt,1,10) create_date
FROM forstdb.retailpromotionitem_dmall d
LEFT JOIN dmall_ware.ware_ware n ON d.sku= n.rf_id
AND n.vender_id=2
LEFT JOIN dmall_ware.ware_sku m ON m.ware_id= n.ware_id
AND m.vender_id=2
left join business_operation.ware_info w on m.sku_id = w.sku_id
WHERE d.enddate>='2018-08-30' ---改时间
  AND ENABLE=1
  AND d.groupid=305 --华北300 华东305 新百 307
ORDER BY start_date DESC
LIMIT 200000
