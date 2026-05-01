select 
    review_score,
    count(*)        as review_count,
    sum(case when delivered_on_time = true then 1 else 0 end) as on_time_orders,
    sum(case when delivered_on_time = false then 1 else 0 end)  as late_orders,
    sum(case when delivered_on_time is null then 1 else 0 end)  as not_delivered,
    from main.fct_customer_orders
where review_score is not null
group by 1
order by 1