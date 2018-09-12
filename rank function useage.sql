SELECT * from 
(SELECT a.sku_name,a.obj_id,a.score,cnt,rank() over (PARTITION BY a.obj_id ORDER BY cnt DESC) rank
from 
(SELECT  b.sku_name, obj_id, a.score, count(a.score) cnt 
from dmall_mongo.rate_ware  a 
LEFT JOIN business_operation.ware_info b 
on a.obj_id = b.sku_id
where vendor_id = 1
and dt >= '20180501'
GROUP BY b.sku_name, obj_id, a.score) a) b
--where rank = 1