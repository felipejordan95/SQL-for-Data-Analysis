-- Inspecting data
SELECT * FROM [dbo].[sales_data_sample]

-- Checking unique values
select distinct status from [dbo].[sales_data_sample] --Nice one to plot
select distinct year_id from [dbo].[sales_data_sample]
select distinct PRODUCTLINE from [dbo].[sales_data_sample] ---Nice to plot
select distinct COUNTRY from [dbo].[sales_data_sample] ---Nice to plot
select distinct DEALSIZE from [dbo].[sales_data_sample] ---Nice to plot
select distinct TERRITORY from [dbo].[sales_data_sample] ---Nice to plot

select distinct MONTH_ID from [dbo].[sales_data_sample]
where year_id = 2003

-----------------------------ANALYSIS--------------------------------------

---Let's start by grouping sales by productline

SELECT PRODUCTLINE, round(sum(sales),2) Revenue
FROM [dbo].[sales_data_sample]
GROUP BY PRODUCTLINE
ORDER BY 2 DESC

SELECT YEAR_ID, round(sum(sales),2) Revenue
FROM [dbo].[sales_data_sample]
GROUP BY YEAR_ID
ORDER BY 2 DESC

SELECT DEALSIZE, round(sum(sales),2) Revenue
FROM [dbo].[sales_data_sample]
GROUP BY DEALSIZE
ORDER BY 2 DESC

---What was the best month for sales in a specific year? How much was earned that month?
SELECT MONTH_ID, sum(sales) Revenue, count(ORDERNUMBER) Frequency
FROM [dbo].[sales_data_sample]
WHERE YEAR_ID=2004  --change year to see the rest
GROUP BY MONTH_ID
ORDER BY 2 DESC

--November seems to be the best month in terms of Revenue & classic are the most sold item
SELECT MONTH_ID, PRODUCTLINE, sum(sales) Revenue, count(ORDERNUMBER) Frequency
FROM [dbo].[sales_data_sample]
WHERE YEAR_ID=2004 and MONTH_ID=11 --change year to see the rest
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC

--Who is our best customer (this could be best answered with RFM)

DROP TABLE IF EXISTS #rfm
;WITH rfm as
(
	SELECT CUSTOMERNAME,
			sum(sales) MonetaryValue,
			avg(sales) AvgMonetaryValue,
			count(*) frequency,
			max(ORDERDATE) last_order_date,
			(select max(ORDERDATE) from [dbo].[sales_data_sample]) max_order_date,
			DATEDIFF(DD,max(ORDERDATE),(select max(ORDERDATE) from [dbo].[sales_data_sample])) Recency
	FROM [dbo].[sales_data_sample]
	GROUP BY CUSTOMERNAME
),
rfm_calc as 
(
	SELECT r.*,
			NTILE(4) OVER(ORDER BY Recency DESC) rfm_recency,--DESC because less Recency means most recent prder
			NTILE(4) OVER(ORDER BY frequency) rfm_frequency,
			NTILE(4) OVER(ORDER BY MonetaryValue) rfm_monetary
	FROM rfm r 
)

SELECT 
	c.*,rfm_recency+rfm_frequency+rfm_monetary AS rfm_cell,
	CAST(rfm_recency as varchar) + CAST(rfm_frequency AS varchar) + CAST(rfm_monetary AS VARCHAR) rfm_cell_string
INTO #rfm
FROM rfm_calc c

SELECT CUSTOMERNAME, rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322,234) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment
FROM #rfm

--What products are most often sold together? With XML path analysis
select distinct OrderNumber, stuff(

	(select ',' + PRODUCTCODE
	from [dbo].[sales_data_sample] p
	where ORDERNUMBER in 
		(

			select ORDERNUMBER
			from (
				select ORDERNUMBER, count(*) rn
				FROM [dbo].[sales_data_sample]
				where STATUS = 'Shipped'
				group by ORDERNUMBER
			)m
			where rn = 3
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path ('')), 1, 1, '') ProductCodes

from [dbo].[sales_data_sample] s
order by 2 desc
