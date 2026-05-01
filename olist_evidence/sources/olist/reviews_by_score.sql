select 
    review_score::varchar as review_score,
    count(*)        as review_count,
    from main.fct_customer_orders
group by 1
order by 1