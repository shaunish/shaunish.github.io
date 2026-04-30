---
title: Understanding E-Commerce through Olist
---

Olist is a large online marketplace based in Brazil. They allow merchants to list products on their platform, and fulfill orders through Olist's delivery network. In other words, it's Brazil's version of Amazon (the company, not the rainforest). Olist is a relatively young company; it was founded in 2015 and is still a private company, although they've garnered hundreds of millions in startup funding from Softbank, Redpoint, and other prominent venture capital firms. 

A few years ago, Olist released [anonymized transaction data](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) from their first two years in business. This is cool! It's rare to get such granular transaction-level data in the e-commerce space, especially from a startup. Let's take a look at it, and see what we can learn.


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

Retailers like Olist know that seasonality is an unavaoidable feature of the industry, but it makes executing during the holidays critical to survival. Since there's sparse data in 2016 and the data ends before the 2018 holiday season, we won't get to see this seasonality repeat in the data. But our second observation is not about what we see on this chart, but what we can infer: that this decline in sales was indeed temporary. Softbank wouldn't have touched this company otherwise!

# Growing, Growing, Gone?

So what's driving the growth we see over 2017? Hypothesis: maybe order value is increasing over time as customers build trust in the platform. Let's dig into the number of orders by month and average order value by month and see what we can find:

<LineChart
    data={revenue_by_month}
    x=month
    y=total_orders
    y2=avg_order_value
    title="Monthly Order Value and Order Count"
/>

Nope! Order value stays pretty much flat throughout this data. Meanwhile, the order count line mirrors the GMV line above. In other words, all growth is driven by increase in order count, not order value. More orders = more revenue, and fewer orders = less revenue. That's interesting! Usually, as a business matures, trust in the platform grows, and people shift more of their spending there over time. You might test out a brand-new platform with a single small purchase, then maybe try a couple more if the experience was good, and then suddenly you're buying all of your groceries online instead of walking one block to the store (yes, I spend way too much on Amazon. Why do you ask?).

But that's not what's happening here at all. Hmm - let's take a closer look into repeat customers. Are they growing over time? We'll look at orders again, but this time broken up into new customers and repeat customers.

```sql monthly_new_vs_returning
select * from olist.monthly_new_vs_returning
```

<BarChart
    data={monthly_new_vs_returning}
    x=month
    y={["first_orders", "repeat_orders"]}
    type=stacked
    title="First vs Repeat Orders by Month"
/>

Here we can see that the proportion of revenue attributable to repeat purchases is small, less than 5%, and it stays that way until the end of the data. For a brand new business, especially a fast-growing one, it makes sense that almost all customers will be first-time users. As the business matures, revenue should shift more and more towards repeat customers - the exact mix will depend on industry, strategy, and company size.

Where should that mix be for Olist? It's instructive here to look at Olist's big American brother: Amazon. As another e-commerce marketplace, Amazon is a great comparison, but unfortunately they don't release their revenue breakdown by first-time and repeat customers. However, I discovered that on their [form 10-K released in 1997](https://s2.q4cdn.com/299287126/files/doc_financials/annual/123197_10k.pdf), they mention that repeat customers made up 58%(!) of their revenue. This is a really interesting comparison - Amazon was launched in July 1995, and so their 1997 numbers represent about two years of data, just as we have with Olist. 

What do we make of the fact that at the same point in the history of Amazon and Olist, Amazon attributes more than half of its revenue to repeat customers, while repeat customers are a rounding error for Olist? Well, in 1997 Amazon reported a whopping $147M in revenue, with 1.5 million customers domestically and internationally, compared to Olist's run rate of less than $2.5M USD by the end of our data. So even though the companies are about the same age, 1997 Amazon may still be more mature than 2018 Olist. But it's an interesting data point - and for Olist management in 2018, this should have been a blinking "Danger!" sign. You just can't build a sustainable business without repeat customers.

# Wait! Come Back!

```sql review_terms
select * from olist.review_terms
```

<BarChart
    data={review_terms}
    x=term
    y=tfidf_score
    title="Top Terms in 1-Star Reviews"
    swapXY=true
/>