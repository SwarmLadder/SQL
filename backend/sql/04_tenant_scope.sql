-- Tenant data isolation requires constraints and tenant-scoped queries.
CREATE TABLE demo_tenant_orders(
 tenant_id TEXT NOT NULL,
 order_id INTEGER NOT NULL,
 amount_cents INTEGER NOT NULL CHECK(amount_cents>=0),
 PRIMARY KEY(tenant_id,order_id)
);
INSERT INTO demo_tenant_orders VALUES
('tenant-a',1,100),('tenant-a',2,200),('tenant-b',1,999);
SELECT order_id,amount_cents FROM demo_tenant_orders
WHERE tenant_id='tenant-a' ORDER BY order_id;
EXPLAIN QUERY PLAN
SELECT order_id,amount_cents FROM demo_tenant_orders
WHERE tenant_id='tenant-a' AND order_id=1;
