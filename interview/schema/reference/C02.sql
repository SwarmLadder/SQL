CREATE TABLE reservations(reservation_id INTEGER PRIMARY KEY,tenant_id TEXT NOT NULL,resource_id TEXT NOT NULL,status TEXT NOT NULL CHECK(status IN ('held','confirmed','cancelled')));
CREATE UNIQUE INDEX uq_active_reservations ON reservations(tenant_id,resource_id) WHERE status IN ('held','confirmed');
