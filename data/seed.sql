INSERT INTO customers VALUES
(1,'Ana Ionescu','ana@example.test','Bucharest','2026-01-05'),
(2,'Bogdan Pop','bogdan@example.test','Cluj-Napoca','2026-01-15'),
(3,'Carmen Radu','carmen@example.test','Iași','2026-02-10'),
(4,'Darius Ene','darius@example.test','Timișoara','2026-02-11'),
(5,'Elena Stan','elena@example.test','Brașov','2026-03-01'),
(6,'Florin Matei','florin@example.test','Constanța','2026-03-10'),
(7,'Gabriela Dinu','gabriela@example.test','Sibiu','2026-04-05'),
(8,'Horia Vlad','horia@example.test','Oradea','2026-05-01');
INSERT INTO categories VALUES (1,'Books'),(2,'Stationery'),(3,'Electronics'),(4,'Home');
INSERT INTO products VALUES
(1,'P01',2,'Notebook',1200,1),
(2,'P02',2,'Pen',250,1),
(3,'P03',1,'Python Handbook',4900,1),
(4,'P04',3,'Keyboard',15900,1),
(5,'P05',4,'Desk Lamp',8900,1),
(6,'P06',2,'Marker',450,1),
(7,'P07',1,'SQL Handbook',5500,1),
(8,'P08',3,'Mouse',6500,1),
(9,'P09',2,'Folder',350,0);
INSERT INTO orders VALUES
(101,1,'2026-01-12','paid'),
(102,2,'2026-02-05','paid'),
(103,1,'2026-03-02','paid'),
(104,3,'2026-03-12','pending'),
(105,4,'2026-04-06','paid'),
(106,5,'2026-04-15','cancelled'),
(107,6,'2026-05-04','paid'),
(108,2,'2026-05-14','pending'),
(109,7,'2026-06-02','paid'),
(110,8,'2026-06-21','paid'),
(111,3,'2026-07-08','paid');
INSERT INTO order_items VALUES
(101,1,2,1200),(101,2,3,250),
(102,3,1,4900),(102,2,2,250),
(103,4,1,15900),(103,8,1,6500),
(104,7,1,5500),
(105,5,2,8900),(105,6,4,450),
(106,3,1,4900),
(107,8,1,6500),(107,1,3,1200),
(108,2,10,250),
(109,7,2,5500),(109,9,1,350),
(110,4,1,15900),(110,2,1,250),
(111,3,1,4900),(111,5,1,8900);
INSERT INTO payments VALUES
(1,101,3150,'card','2026-01-12'),
(2,102,5400,'transfer','2026-02-05'),
(3,103,22400,'card','2026-03-02'),
(4,105,19600,'cash','2026-04-06'),
(5,107,10100,'card','2026-05-04'),
(6,109,11350,'transfer','2026-06-02'),
(7,110,16150,'card','2026-06-21'),
(8,111,13800,'card','2026-07-08');
INSERT INTO teams VALUES (1,'Engineering'),(2,'Sales'),(3,'Support');
INSERT INTO employees VALUES
(1,'Ada',1,12000000,NULL),
(3,'Cleo',2,9500000,NULL),
(5,'Ema',3,6500000,NULL),
(2,'Ben',1,8500000,1),
(4,'Dina',2,7000000,3),
(6,'Fadi',1,7500000,1),
(7,'Gina',3,5000000,5),
(8,'Hugo',2,6800000,3);
INSERT INTO audit_events VALUES
(1,'order_paid','2026-01-12','{"order_id":101}'),
(2,'order_paid','2026-02-05','{"order_id":102}'),
(3,'order_paid','2026-03-02','{"order_id":103}'),
(4,'order_created','2026-03-12','{"order_id":104}'),
(5,'order_paid','2026-04-06','{"order_id":105}'),
(6,'order_cancelled','2026-04-15','{"order_id":106}'),
(7,'order_paid','2026-05-04','{"order_id":107}'),
(8,'order_paid','2026-06-02','{"order_id":109}'),
(9,'order_paid','2026-06-21','{"order_id":110}');
