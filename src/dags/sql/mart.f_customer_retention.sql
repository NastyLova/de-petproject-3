delete
from mart.f_customer_retention cr
where
	cr.period_id in (
	select week_of_year || '_' || year_actual
	from mart.d_calendar dc
	where dc.week_of_year = extract('week' from '{{ds}}'::date) 
	and dc.year_actual = extract('year' from '{{ds}}'::date));

insert
	into
	mart.f_customer_retention (new_customers_count,
	returning_customers_count,
	refunded_customer_count,
	period_name,
	period_id,
	item_id,
	new_customers_revenue,
	returning_customers_revenue,
	customers_refunded)
with customer_counts as (
	select
		fs.customer_id,
		fs.status,
		fs.payment_amount,
		dc.week_of_year,
		dc.year_actual,
		fs.item_id,
		count(case when fs.status = 'shipped' then fs.item_id end) over(partition by fs.customer_id) cnt_shipped,
		count(case when fs.status = 'refunded' then fs.item_id end) over(partition by fs.customer_id) cnt_refunded
	from mart.f_sales fs
	inner join mart.d_calendar dc on dc.date_id = fs.date_id
	where dc.week_of_year = extract('week' from '{{ds}}'::date)
	and dc.year_actual = extract('year' from '{{ds}}'::date))

select  sum(case when cnt_shipped = 1 then 1 else 0 end) as new_customers_count,
		sum(case when cnt_shipped > 1 then 1 else 0 end) as returning_customers_count,
		sum(case when cnt_refunded > 0 then 1 else 0 end) as refunded_customer_count,
		'weekly' as period_name,
		week_of_year || '_' || year_actual as period_id,
		item_id,
		coalesce(sum(case when cnt_shipped = 1 then payment_amount end), 0) as new_customers_revenue,
		coalesce(sum(case when cnt_shipped > 1 then payment_amount end), 0) as returning_customers_revenue,
		count(cnt_refunded) as customers_refunded
from customer_counts
group by
	year_actual,
	week_of_year,
	item_id;