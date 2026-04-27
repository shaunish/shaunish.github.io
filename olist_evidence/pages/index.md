---
title: Olist Customer Analytics
---

# Olist Customer Behavior Analysis

An analysis of customer purchasing patterns from the 
[Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

## Revenue Over Time

Is Olist growing? Monthly revenue from delivered orders.

```sql revenue_by_month
select * from olist.revenue_by_month
```

<LineChart
    data={revenue_by_month}
    x=month
    y=total_revenue
    title="Monthly Revenue"
    yAxisTitle="Revenue in BRL"
/>