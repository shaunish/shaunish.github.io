---
title: "Olist: An E-Commerce Marketplace Case Study"
---

<a href="https://pt.wikipedia.org/wiki/Olist" target="_blank" style="color: blue;">Olist</a> is a large online marketplace based in Brazil. They allow merchants to list products on their platform and fulfill orders through Olist's delivery network. In other words, it's Brazil's version of Amazon (the company, not the rainforest). Olist is a relatively young company; it was founded in 2015 and is still a private company, although they've garnered hundreds of millions in startup funding from Softbank, Redpoint, and other prominent venture capital firms. 

A few years ago, Olist released <a href="https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce" target="_blank" style="color: blue;">anonymized transaction data</a> from their first two years in business. This is cool! It's rare to get such granular transaction-level data in the e-commerce space, especially from a startup. Let's take a look at it and see what we can learn.

(I organized all the data used in this project using the dbt platform and DuckDB - you can check it out <a href="https://github.com/shaunish/olist_dbt" target="_blank" style="color: blue;">here</a>. All the charts were made using <a href="https://evidence.dev" target="_blank" style="color: blue;">Evidence.dev</a>. If you want to check out the source code, it's available at my Github <a href="https://github.com/shaunish/shaunish.github.io/tree/master/olist" target="_blank" style="color: blue;">here</a>.)


# 'Tis the Season

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

Two more related observations about this graph. First, there's a spike in sales in November 2017, followed by a plateau and slight decline into the middle of 2018. While this chart might give those used to SaaS businesses palpitations, this isn't surprising in e-commerce and retail, where the Q4 holiday season is almost always the busiest period, while summers tend to be quieter. Consumers like to make a lot of purchases around the holiday season, due to gifts, holiday bonuses, and aggressive retail promotions. These effects pull demand towards the holidays, resulting in spikes in Q4 just as we see here. In fact, it's not uncommon for a retailer to make 40% of its annual revenue in just the last quarter of the year.

Retailers like Olist know that seasonality is an unavoidable feature of the industry, but it makes executing during the holidays critical to survival. Since there's sparse data in 2016 and the data ends before the 2018 holiday season, we won't get to see this seasonality repeat in the data. But our second observation is not about what we see on this chart, but what we can infer: that this decline in sales was indeed temporary - or that there was a business model pivot. Softbank wouldn't have touched this company otherwise!

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

Here we can see that the proportion of revenue attributable to repeat purchases is barely visible, and although it grows slightly over time, it never reaches even 5% of purchases. For a brand new business, especially a fast-growing one, it makes sense that almost all customers will be first-time users. As the business matures, revenue should shift more and more towards repeat customers - the exact revenue mix will depend on industry, strategy, and company size.

Where should that mix be for Olist? It's instructive here to look at Olist's American big brother: Amazon. As another e-commerce marketplace, Amazon is a great comparison, but unfortunately they don't release their revenue breakdown by first-time and repeat customers. However, I discovered that on their <a href="https://s2.q4cdn.com/299287126/files/doc_financials/annual/123197_10k.pdf" target="_blank" style="color: blue;">form 10-K released in 1997</a>, they mention that repeat customers made up 58%(!) of their revenue. This is a really interesting comparison - Amazon was launched in July 1995, and so their 1997 numbers represent about two years of data, just as we have with Olist. 

What do we make of the fact that at the same point in the history of Amazon and Olist, Amazon attributes more than half of its revenue to repeat customers, while repeat customers are a rounding error for Olist? Well, in 1997 Amazon reported a whopping $147M in revenue, with 1.5 million customers domestically and internationally, compared to Olist's run rate of less than $2.5M USD by the end of our data. So even though the companies are about the same age, 1997 Amazon may still be more mature than 2018 Olist. But it's an interesting data point - and for Olist management in 2018, this should have been a blinking "Danger!" sign. You just can't build a sustainable business without repeat customers.

# Wait! Come Back!

Okay, so customers are trying the product once and not returning. Why? Two broad possibilities - either they will return but they haven't yet, or they had a bad experience and won't. Luckily for us, we can see which category Olist customers fall into, because whenever customers make a purchase, Olist asks them to rate their experience from 1 to 5 and leave a review. So let's see how people felt about their experience:

```sql reviews_by_score
select * from olist.reviews_by_score
```
<ECharts config= {
    {
        title: {text: 'Review Score Percentages'},
        tooltip: { trigger: 'item', formatter: '{b}: {d}%' },
        series: [{
            type: 'pie',
            data: reviews_by_score.map(d => ({
                name: String(d.review_score) + ' star',
                value: d.review_count
            }))
        }]
    }
}/>

Not too bad! More than 75% of customers left either a 4 star or 5 star review, and the average rating comes out to 4.08 stars out of 5. So we can assume that these happy reviewers might return in the future, even if they haven't yet. In this case, it's possible that Olist should focus on expanding its product offerings or minimizing out-of-stocks. Why? Because if a customer can't find the product they're looking for in the first place, they'll never place an order - and won't leave a bad review. These lost sales are invisible to us, although they might be detectable in increased website traffic and searches that never result in a sale.

We don't have the Olist website traffic data to confirm this. But we do have 11.51% of customers that were very unhappy with their experience and left a one-star review. Can we figure out what they didn't like, maybe using a little NLP and elbow grease? To investigate, let's calculate the <a href="https://en.wikipedia.org/wiki/Tf%E2%80%93idf" target="_blank" style="color: blue;">TF-IDF score</a> for each word and 2-word phrase in every one-star review. We can use the open-source <a href="https://spacy.io/" target="_blank" style="color: blue;">spaCy</a> NLP library to clean up the text before we analyze it, and scikit-learn has a great <a href="https://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.TfidfTransformer.html" target="_blank" style="color: blue;">TF-IDF library</a>. After running <a href="https://github.com/shaunish/olist_dbt/blob/main/nlp_analysis.py" target="_blank" style="color: blue;">the script</a>, here's what we get: the top thirty most relatively frequent terms that show up in one-star reviews (remember that Olist customers, being Brazilian, leave comments in Portuguese).

```sql review_terms
select * from olist.review_terms
```

<BarChart
    data={review_terms}
    x=term
    y=tfidf_score
    title="Top Thirty Terms in 1-Star Reviews"
    swapXY=true
/>

Much of what we see are generic terms like 'produto' (product) and 'comprei' (I bought). But there is a theme that emerges. We see 'entregar' and 'entrega' (delivery) near the top, 'chegar' (to arrive), 'vir' (to come), 'esperar' and 'aguardar' (to wait), 'correio' (mail), 'enviar' (to send) - all likely references to the *delivery* of the product. These seem to be more common than complaints about, say, the 'qualidade' (quality) of the product. This isn't definitive proof of anything, but it does <a href="https://xkcd.com/552/" target="_blank" style="color: blue;">waggle its eyebrows suggestively</a>: are unhappy customers receiving their orders late? Let's take a look!

```sql reviews_by_score
select * from olist.reviews_by_score
```

<BarChart
    data={reviews_by_score}
    x=review_score
    y={["on_time_orders", "late_orders", "not_delivered"]}
    type=stacked
    title="Delivery status by Review Score"
/>

Yes! Almost half of customers that gave a one-star review either received their order late, or never received it at all. Compare that to four- and five-star reviews, where almost every order is delivered on time. This suggests that if Olist wants to improve customer satisfaction, improving their last-mile will have huge ROI, plausibly reducing one-star reviews by up to 50%. Again, it's hard not to compare Olist to Amazon, which has invested an enormous amount of capital into owning and operating their own proprietary and ruthlessly efficient delivery network. It's worth it; the data shows that customers really really hate getting their packages late.

So if I was advising Olist in the summer of 2018, and they handed me this data, I'd tell them that their problem isn't the recent dip in sales - it's that customers aren't coming back. Make sure that customers can actually find what they're looking for, and then get it to them on time. If I had the data, what I'd dive into next would be website traffic and customer demographics. That's where we could start finding even more of the "why" behind this company's performance.

Thanks for reading!