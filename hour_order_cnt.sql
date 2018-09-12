SELECT to_date(order_create_time) create_date,
       sale_type,
       hour(order_create_time) create_hour,
       count(DISTINCT coalesce(parent_id, id)) order_cnt
FROM dmall_order.wm_order
WHERE vender_id = 2
  AND order_type = 1
  AND sale_type IN (1, 2)
  AND order_status = 1024
  AND dt >= '20180709'
  AND dt <= '20180808'
GROUP BY to_date(order_create_time),
         hour(order_create_time),
         sale_type