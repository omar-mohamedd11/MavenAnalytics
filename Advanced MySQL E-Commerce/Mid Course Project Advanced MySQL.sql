-- Mid Course Project
/* Q1 Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions
and orders so that we can showcase the growth there? */

select 
	year(w.created_at) as year,
    month(w.created_at) as month,
    count(w.website_session_id) sessions,
	count(o.order_id) orders,
    concat(round((count(o.order_id) / count(w.website_session_id) *100),1),'%') CVR
from website_sessions w
left join orders o
	on o.website_session_id = w.website_session_id
where w.created_at < '2012-11-27' 
and w.utm_source = 'gsearch'
group by 1,2;

/* Q2 Next, it would be great to see a similar monthly trend for Gsearch,
 but this time splitting out nonbrand and  brand campaigns separately,
 I am wondering if brand is picking up at all. If so, this is a good story to tell. */

select 
	year(w.created_at) as year,
    month(w.created_at) as month,
    count(case when utm_campaign = 'brand' then w.website_session_id else null end) brand_sessions,
    count(case when utm_campaign = 'nonbrand' then w.website_session_id else null end) nonbrand_sessions,
	count(case when utm_campaign = 'brand' then o.order_id else null end) brand_orders,
    count(case when utm_campaign = 'nonbrand' then o.order_id else null end) nonbrand_orders,
    concat('% ', round(((count(case when utm_campaign = 'brand' then o.order_id else null end) /
		count(case when utm_campaign = 'brand' then w.website_session_id else null end) ) *100),1)) Brand_CVR,
	concat('% ',round(((count(case when utm_campaign = 'nonbrand' then o.order_id else null end) /
		count(case when utm_campaign = 'nonbrand' then w.website_session_id else null end) ) *100),1)) nonBrand_CVR
from website_sessions w
left join orders o
	on o.website_session_id = w.website_session_id
where w.created_at < '2012-11-27' 
and w.utm_source = 'gsearch'
group by 1,2;

/* Q3 While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device
type? I want to flex our analytical muscles a little and show the board we really know our traffic sources.
*/
select 
	year(w.created_at) year,
    month(w.created_at) month,
    w.device_type,
    count(w.website_session_id) sessions,
    count(o.order_id) orders,
    concat(round((count(o.order_id) / count(w.website_session_id)) *100,2),'%') CVR
from website_sessions w
left join orders o
	on o.website_session_id = w.website_session_id
where w.created_at < '2012-11-27'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by 1,2,3;

/* Q4 I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from
Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?
*/
select 
	year(w.created_at) as year,
    month(w.created_at) as month,
    count(case when utm_source = 'gsearch' then w.website_session_id else null end ) gsearch_paid_sessions,
    count(case when utm_source = 'bsearch' then w.website_session_id else null end ) bsearch_paid_sessions,
    count(case when utm_source is null 
			and http_referer is not null then w.website_session_id else null end ) organic_sessions,
    count(case when utm_source is null  and http_referer is null 
				then w.website_session_id else null end ) Direct_sessions
from website_sessions w
left join orders o
	on o.website_session_id = w.website_session_id
where w.created_at < '2012-11-27'
group by 1,2;
    

select 
	year(w.created_at) year,
    month(w.created_at) month,
    count(w.website_session_id) sessions,
    count(o.order_id) orders,
    concat('% ',round((count(o.order_id) / count(w.website_session_id) *100),2)) CVR
from website_sessions w
left join orders o
	on o.website_session_id = w.website_session_id
where w.created_at < '2012-11-27'
group by 1,2;


/* Q5 I’d like to tell the story of our website performance improvements over the course of the first 8 months.
Could you pull session to order conversion rates, by month?
*/
select 
    year(w.created_at) as year,
    month(w.created_at) as month,
    count(distinct w.website_session_id) as sessions,
    count(distinct o.order_id) as orders,
    concat(round(100 * (count(distinct o.order_id) / count(distinct w.website_session_id)), 1), '%') as cvr
from website_sessions w
    left join orders o
        on w.website_session_id = o.website_session_id
where w.created_at < '2012-11-27'
group by 1, 2;


/* Q6 For the gsearch lander test, please estimate the revenue that test earned us
	(Hint: Look at the increase in CVR  from the test (Jun 19 – Jul 28),
    and use nonbrand sessions and revenue since then to calculate incremental value) */
-- Find lander-1 when test was created
SELECT 
    MIN(created_at) created_at,
    MIN(website_pageview_id) AS lander1_id
FROM website_pageviews
WHERE pageview_url = '/lander-1';


-- it was created at 2012-06-19 00:35:54 and pageview_id start at 23504

-- Find the first website_pageview_id, retricting to home and lander-1
CREATE TEMPORARY TABLE landing_page_testt
SELECT
    p.website_session_id,
    MIN(p.website_pageview_id) AS min_pageview_id,
    p.pageview_url AS landing_page
FROM website_pageviews p
    JOIN website_sessions s
        ON s.website_session_id = p.website_session_id
        AND s.created_at < '2012-07-28'
        AND s.utm_source = 'gsearch'
        AND s.utm_campaign ='nonbrand'
        AND p.website_pageview_id >= 23504 -- = at 2012-06-19
WHERE p.pageview_url IN ('/home', '/lander-1')
GROUP BY 1, 3;

-- Join the result with order_id and aggregat for session, order, and cvr
WITH session_order_landing AS
(
    SELECT 
        t.website_session_id,
        t.landing_page,
        o.order_id
    FROM landing_page_testt t
        LEFT JOIN orders o
            ON t.website_session_id = o.website_session_id
)
SELECT 
    landing_page,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    concat(ROUND(100*(COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id)),1),'%') AS CVR
FROM session_order_landing
GROUP BY 1;


/* find most recent pageview for 
	gsearch nonbrand where traffic was sent to /home */
SELECT
    MAX(s.website_session_id) ID
FROM website_sessions s
    LEFT JOIN website_pageviews p
        ON s.website_session_id = p.website_session_id
WHERE s.created_at < '2012-11-27'
    AND s.utm_source = 'gsearch'
    AND s.utm_campaign = 'nonbrand'
    AND p.pageview_url = '/home';
    -- result: the recent website_session_id = 17145
    
SELECT
    COUNT(website_session_id) AS session_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
    AND website_session_id > 17145 ;
-- result: there are 22972 session since the test
    
/*We can estimate the increase in revenue from the increase in orders :
22972 session x 1.08% (incremental % of order) = 248
So, estimated at least 248 incremental orders since 29 Jul using the lander-1 page
Calculate monthly increase (July - November) :
248 / 4 = 64 additional order/month
*/

/* Q7 For the landing page test you analyzed previously,
 it would be great to show a full conversion funnel from each  of the two pages to orders.
 You can use the same time period you analyzed last time (Jun 19 – Jul 28). */

-- find all pageview_url from two pages (Jun 19 – Jul 28)
SELECT DISTINCT
    p.pageview_url
FROM website_pageviews p
    LEFT JOIN website_sessions s
        ON p.website_session_id = s.website_session_id
WHERE p.created_at < '2012-11-27'
    AND s.utm_source = 'gsearch'
    AND s.utm_campaign = 'nonbrand'
    AND p.website_pageview_id >= 23504;

-- Create summary all pageviews for relevant session
CREATE TEMPORARY TABLE pageview_levelss
WITH pageviews_cte AS
(
    SELECT
        s.website_session_id,
        p.created_at,
        p.pageview_url,
        CASE WHEN p.pageview_url = '/home' THEN 1 ELSE 0 END AS home_p,
        CASE WHEN p.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander1_p,
        CASE WHEN p.pageview_url = '/products' THEN 1 ELSE 0 END AS product_p,
        CASE WHEN p.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_p,
        CASE WHEN p.pageview_url = '/cart' THEN 1 ELSE 0 END AS chart_p,
        CASE WHEN p.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_p,
        CASE WHEN p.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_p,
        CASE WHEN p.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_p
    FROM website_sessions s
        LEFT JOIN website_pageviews p
            ON s.website_session_id = p.website_session_id
    WHERE s.created_at BETWEEN '2012-06-19' AND '2012-07-28'
        AND p.website_pageview_id >= 23504 
        AND s.utm_source = 'gsearch'
        AND s.utm_campaign ='nonbrand'
        AND p.pageview_url IN ('/home', '/lander-1', '/products',
		'/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
    ORDER BY 1, 2
)
SELECT
    website_session_id, 
    MAX(home_p) AS home_page,
    MAX(lander1_p) AS lander1_page,
    MAX(product_p) AS product_page,
    MAX(mrfuzzy_p) AS mrfuzzy_page,
    MAX(chart_p) AS chart_page,
    MAX(shipping_p) AS shipping_page,
    MAX(billing_p) AS billing_page,
    MAX(thankyou_p) AS thankyou_page
FROM pageviews_cte
GROUP BY 1;

-- Categorise website sessions under `segment` by 'saw_home_page' or 'saw_lander_page'
-- Aggregate data to assess funnel performance
CREATE TEMPORARY TABLE session_page
    SELECT 
        CASE 
            WHEN home_p = 1 THEN 'saw_home_page'
            WHEN lander1_p = 1 THEN 'saw_lander_page'
            ELSE 'can_not_identify'
        END AS segment,
        COUNT(DISTINCT website_session_id) AS sessions,
        COUNT(DISTINCT CASE WHEN product_p = 1 THEN website_session_id ELSE NULL END) AS to_product,
        COUNT(DISTINCT CASE WHEN mrfuzzy_p = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
        COUNT(DISTINCT CASE WHEN chart_p = 1 THEN website_session_id ELSE NULL END) AS to_chart,
        COUNT(DISTINCT CASE WHEN shipping_p = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
        COUNT(DISTINCT CASE WHEN billing_p = 1 THEN website_session_id ELSE NULL END) AS to_billing,
        COUNT(DISTINCT CASE WHEN thankyou_p = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM pageview_levels
GROUP BY 1;

-- Convert aggregated website sessions to percentage of click rate by dividing by total sessions
select
    segment,
    sessions,
    concat(round(100 * (to_product / sessions), 1), '%') as segment_clickrate,
    concat(round(100 * (to_mrfuzzy / to_product), 1), '%') as product_clickrate,
    concat(round(100 * (to_chart / to_mrfuzzy), 1), '%') as mrfuzzy_clickrate,
    concat(round(100 * (to_shipping / to_chart), 1), '%') as chart_clickrate,
    concat(round(100 * (to_billing / to_shipping), 1), '%') as shipping_clickrate,
    concat(round(100 * (to_thankyou / to_billing), 1), '%') as billing_clickrate
from session_page;



/* Q8 I’d love for you to quantify the impact of our billing test,
 as well. Please analyze the lift generated from the test
 (Sep 10 – Nov 10), in terms of revenue per billing page session,
 and then pull the number of billing page sessions  for the past month to understand monthly impact. */
-- Find billing-2 test was created
SELECT 
    MIN(created_at) created_at,
    MIN(website_pageview_id) AS lander1_pv
FROM website_pageviews
WHERE pageview_url = '/billing-2';

-- it was cheates at 2012-09-10 00:13:05 billing 2 page view start from 53550
-- that's make sense (Sep 10 – Nov 10)

WITH billing_cte AS
(
    SELECT
        p.website_session_id,
        p.pageview_url,
        o.price_usd
    FROM website_pageviews p
        LEFT JOIN orders o
            ON p.website_session_id = o.website_session_id
    WHERE p.created_at BETWEEN '2012-09-10' AND '2012-11-10'
        AND p.pageview_url IN ('/billing', '/billing-2')
)
SELECT 
    pageview_url AS billing_page,
    COUNT(DISTINCT website_session_id) AS sessions,
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page
FROM billing_cte
GROUP BY 1;

-- calculate billing page sessions for the past month
SELECT 
    COUNT(website_session_id) AS sessions
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-27' AND '2012-11-27'
    AND pageview_url IN ('/billing', '/billing-2');
    
/* We can calculate from the past month :
Total session a month = 1193
Value billing test = 1193 X 8.51 (lift) = 10152.43
So there are 1193 sessions and with the increase of 8.51 dolar average
revenue per session with a positive impact 10152.43 dolar increase in revenue.
*/