CREATE TABLE reviews (
  customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
  product_id INTEGER NOT NULL REFERENCES products(product_id),
  stars INTEGER NOT NULL CHECK (stars BETWEEN 1 AND 5),
  UNIQUE (customer_id, product_id)
);
