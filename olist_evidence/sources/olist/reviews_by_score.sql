select 
    review_score::varchar as review_score,
    count(*)        as review_count,
    from main.fct_customer_orders
where review_score is not null
group by 1
order by 1