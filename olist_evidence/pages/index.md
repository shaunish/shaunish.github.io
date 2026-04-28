---
title: Understanding E-Commerce through Olist
---

Olist is a large online marketplace in Brazil. They allow merchants to list products on their platform, and fulfill orders through Olist's delivery network. In other words, it's Brazil's version of Amazon (the company, not the rainforest). Olist is a relatively young company; it was founded in 2015 and is still a private company, although they've garnered hundreds of millions in startup funding from Softbank, Redpoint, and other prominent venture capital firms. 

A few years ago, Olist released [anonymized transaction data](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) from their first two years in business. This is cool! It's rare to get such granular transaction-level data, especially from a startup. Let's take a look at it, and see what we can learn about e-commerce.


# GMV Growth and Seasonality

The first thing we want to understand is: how is Olist doing as a business? Are they growing over time? Let's look at total GMV by month over these two years:

```sql revenue_by_month
select * from olist.revenue_by_month
```

<LineChart
    data={revenue_by_month}
    x=month
    y=total_revenue
    title="Monthly GMV"
    yAxisTitle="Olist GMV in BRL"
/>

They certainly are growing! After a sputtering launch at the end of 2016, Olist shows strong growth in 2017, going from close to zero to over R$1.15 million BRL (around $230,000 USD at today's exchange rate) in their strongest month in November. Notice that this chart shows GMV, not revenue - as a marketplace, Olist will get a portion of sales as their revenue, and the rest will pass through to the merchant.

Two more related observations about this graph - first, there's a spike in sales in November 2017, followed by a plateau and slight decline into summer of 2018. While this chart might give those used to SaaS businesses palpitations, this isn't surprising in e-commerce and retail, where the Q4 holiday season is almost always the busiest period, while summers tend to be quieter. Consumers like to make a lot of purchases around the holiday season, due to gifts, holiday bonuses, and aggressive retail promotions. At the same time, summers are when people spend on travel, restaurants, and experiences, not consumer goods. These effects pull demand towards the holidays, resulting in spikes in Q4 just as we see here. In fact, it's not uncommon for a retailer to make 40% of its annual revenue in just the last quarter of the year.

Retailers like Olist know that seasonality is a large part of the business model, but it makes executing during the holidays critical to survival. Since there's sparse data in 2016 and the data ends before the 2018 holiday season, we won't get to see this seasonality repeat in the data. But our second observation is about not what we see on this chart, but what we can infer: that this decline in sales was indeed temporary. Softbank wouldn't have touched this company otherwise!

# Growing, Growing, Gone?

So what's driving the growth we see over 2017? Hypothesis: maybe order value is increasing over time as customers build trust in the platform. Let's dig into the number of orders by month and average order value by month and see what we can find:

<LineChart
    data={revenue_by_month}
    x=month
    y=order_count
    y2=avg_order_value
    title="Monthly Order Value and Order Count"
/>

Nope! Order value stays pretty much flat throughout this data. Meanwhile, the order count line mirrors the GMV line above. In other words, all growth is driven by increase in order count, not order value. More orders = more revenue, and fewer orders = less revenue. That's interesting! Usually, as a business matures, trust in the platform grows, and people shift more of their spending there over time. You might test out a brand-new platform with a single small purchase, then maybe try a couple more if the experience was good, and then suddenly you're buying all of your groceries online instead of walking one block to the store (yes, I spend way too much on Amazon. Why do you ask?).

But that's not what's happening here at all. Hmm - let's take a closer look into repeat customers. We'll look at order count again, but this time broken up into new customers and repeat customers.

<LineChart
    data={revenue_by_month}
    x=month
    y=first_orders
    y2=repeat_orders
    title="Monthly New Vs. Repeat Orders"
/>