with cte_sales as(
	select 
		t1.customerNumber, 
		t1.creditLimit, 
		t2.orderDate,
		lead(t2.orderDate) over (partition by t1.customernumber order by t2.orderdate) as next_order_date, 
		t3.orderNumber, 
		sum(t3.priceEach*t3.quantityOrdered) as orderValue
	from classicmodels.customers t1
	inner	join classicmodels.orders t2
	on t1.customerNumber = t2.customerNumber
	inner join classicmodels.orderdetails t3
	on t3.orderNumber = t2.orderNumber
	group by t1.customerNumber, t3.orderNumber
	order by t1.customerNumber, t2.orderDate
),

cte_payment as (
	select *, sum(amount) over (partition by t1.customernumber order by paymentdate) as running_payment
	from classicmodels.payments t1
	order by t1.customernumber
),
payments as

(select *, row_number() over (partition by customernumber order by paymentDate) as payment_number

from classicmodels.payments p

),

cte_main as (
select 
	t1.*, 
	sum(orderValue) over (partition by t1.customernumber order by t1.orderdate) as running_total_sales,
	sum(amount) over (partition by t1.customernumber order by t1.orderdate) as running_payment,
		sum(orderValue) over (partition by t1.customernumber order by t1.orderdate) - sum(amount) over (partition by t1.customernumber order by t1.orderdate)
        as money_owned

from cte_sales t1
left join payments t2
on t1.customerNumber=t2.customerNumber 
and t2.paymentdate between t1.orderdate and 
	case when t1.next_order_date is null then curdate() else t1.next_order_date end
order by t1.customerNumber, t1.orderdate)

select *, case when creditlimit - money_owned <0 then "overLimit" else null end as overLimit,  creditlimit - money_owned
from cte_main
-- select *
-- from cte_main
-- where customerNumber = 450
;

