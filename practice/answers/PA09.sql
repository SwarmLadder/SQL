CREATE TABLE category_views (category_id INTEGER PRIMARY KEY, views INTEGER NOT NULL);
INSERT INTO category_views VALUES (1, 1) ON CONFLICT(category_id) DO UPDATE SET views = views + 1;
INSERT INTO category_views VALUES (2, 1) ON CONFLICT(category_id) DO UPDATE SET views = views + 1;
INSERT INTO category_views VALUES (1, 1) ON CONFLICT(category_id) DO UPDATE SET views = views + 1;
INSERT INTO category_views VALUES (3, 1) ON CONFLICT(category_id) DO UPDATE SET views = views + 1;
INSERT INTO category_views VALUES (1, 1) ON CONFLICT(category_id) DO UPDATE SET views = views + 1;
