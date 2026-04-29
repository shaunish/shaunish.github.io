select
    date_trunc('month', ordered_at)::date   as month,
    count(order_id)                         as total_orders,
    round(sum(total_payment), 2)            as total_revenue,
    round(avg(total_payment), 2)            as avg_order_value,
    round(100.0 * count(order_id) filter (
        where is_repeat_purchase = false
    ) / count(order_id), 1)                 as first_order_pct,
    round(100.0 * count(order_id) filter (
        where is_repeat_purchase = true
    ) / count(order_id), 1)                 as repeat_order_pct
from main.fct_customer_orders
where order_status = 'delivered'
group by 1
order by 1