select
    date_trunc('month', ordered_at)::date   as month,
    round(sum(total_payment), 2)            as total_revenue,
    count(distinct order_id)                as order_count,
    round(avg(total_payment), 2)            as avg_order_value,
    count(distinct order_id) filter (
        where customer_order_sequence = 1
    )                                       as first_orders,
    count(distinct order_id) filter (
        where customer_order_sequence > 1
    )                                       as repeat_orders
from main.fct_customer_orders
where order_status = 'delivered'
group by 1
order by 1