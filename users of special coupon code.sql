拥有某张优惠券的所有用户
select c.cus_id,c.is_used,c.is_past,c.order_id
FROM dmall_coupon.coup_coupon 
ON c.coupon_apply_id = a.id
where a.code in ('201708007303','201708004103')
and c.dt>='20170801'
