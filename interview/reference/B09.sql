SELECT i.order_id,p.product_name,i.quantity,i.quantity*i.unit_price_cents AS line_cents FROM order_items i JOIN products p ON p.product_id=i.product_id ORDER BY i.order_id,p.product_name;
