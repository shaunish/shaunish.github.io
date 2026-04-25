---
title: Olist Customer Analytics
---

# Olist Customer Behavior Analysis

An analysis of customer purchasing patterns from the 
[Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

## Customer Segments

```sql customer_segments
select * from olist.ltv_by_segment
```

<BarChart 
    data={ltv_by_segment}
    x=customer_segment
    y=avg_ltv
    title="Customer Lifetime Value by Segment"
/>

<DataTable data={ltv_by_segment}/>