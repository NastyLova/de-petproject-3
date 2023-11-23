ALTER TABLE staging.user_order_log ADD status varchar NULL;
ALTER TABLE mart.f_sales ADD status varchar NOT null default 'shipped';
ALTER TABLE mart.f_sales ADD CONSTRAINT f_sales_check CHECK (status in ('refunded', 'shipped'));

DROP TABLE IF EXISTS mart.f_customer_retention;

CREATE TABLE mart.f_customer_retention (
	id serial4 NOT NULL,
	new_customers_count int8 NULL,
	returning_customers_count int8 NULL,
	refunded_customer_count int8 NULL,
	period_name varchar NULL,
	period_id varchar NULL,
	item_id int8 NULL,
	new_customers_revenue numeric(14, 2) NULL,
	returning_customers_revenue numeric(14, 2) NULL,
	customers_refunded int8 NULL,
	CONSTRAINT f_customer_retention_pk PRIMARY KEY (id)
);