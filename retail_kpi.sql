SELECT
    (TO_CHAR(DATE_TRUNC('week', convert_timezone(stores.store_region_timezone, f_order_items.order_completed_at) ), 'YYYY-MM-DD')) AS Order_date_week,
    stores.store_name,
    case
        when products.product_name_english = 'Casper Mattress 2023' then 'Casper Mattresses 2023'
        when (products.product_name_english = 'Element Pro' or products.product_name_english = 'Element Foam') then 'Element Mattresses'
        when (products.product_name_english = 'Nova Hybrid' or products.product_name_english = 'Nova Hybrid Snow') then 'Nova Mattresses'
        when (products.product_name_english = 'Original Hybrid' or products.product_name_english = 'Original Foam') then 'Original Mattresses'
        when (products.product_name_english = 'Snow Mattress 2023' or products.product_name_english = 'Snow Max Mattress') then 'Snow Mattresses 2023'
        when products.product_name_english = 'Snug' then 'Snug Mattresses'
        when (products.product_name_english = 'Wave Hybrid' or products.product_name_english = 'Wave Hybrid Snow') then 'Wave Mattresses'
        when products.product_category is null then 'Other'
        else products.product_category
        end AS Product_category,
    COUNT(DISTINCT f_order_items.order_items_id ) AS Units,
    sum(f_order_items.non_tax_price_amt_usd + f_order_items.dist_promo_amt_usd) as NoP_Revenue,
    sum(f_order_items.non_tax_price_amt_usd) as Gross_revenue
FROM
    elsa.f_order_items_union AS f_order_items
    LEFT JOIN elsa.dim_store_union AS stores ON f_order_items.store_code = stores.store_code
    LEFT JOIN elsa.dim_store_product AS products ON f_order_items.variant_sku = products.variant_sku
WHERE ((( convert_timezone(stores.store_region_timezone, f_order_items.order_completed_at)  ) >= (TIMESTAMP '2023-01-01')
            AND ( convert_timezone(stores.store_region_timezone, f_order_items.order_completed_at)  ) < (TIMESTAMP '2023-08-01')))
  AND (NOT "f_order_items"."is_free_order" OR "f_order_items"."is_free_order" IS NULL)
  AND "f_order_items"."is_order_complete"
  AND "stores"."store_category" = 'US-Retail'
group by 1,2,3
order by 1,2,3
