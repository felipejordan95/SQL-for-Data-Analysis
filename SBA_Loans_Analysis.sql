--- What is the summary of all approved PPP Loans
SELECT 
	year(DateApproved) as year_approved,
	count(LoanNumber) as Number_of_Approved,
	sum(InitialApprovalAmount) as Approved_Amount,
	avg(InitialApprovalAmount) as Average_loan_size
FROM [Projects].[dbo].[sba_public_data]
WHERE
	year(DateApproved)=2020
GROUP BY 
	year(DateApproved)

union

SELECT 
	year(DateApproved) as year_approved,
	count(LoanNumber) as Number_of_Approved,
	sum(InitialApprovalAmount) as Approved_Amount,
	avg(InitialApprovalAmount) as Average_loan_size
FROM [Projects].[dbo].[sba_public_data]
WHERE
	year(DateApproved)=2021
GROUP BY year(DateApproved)

--------------------------------------------------------
SELECT 
	count (distinct OriginatingLender) as OriginatingLender,
	year(DateApproved) as year_approved,
	count(LoanNumber) as Number_of_Approved,
	sum(InitialApprovalAmount) as Approved_Amount,
	avg(InitialApprovalAmount) as Average_loan_size
FROM [Projects].[dbo].[sba_public_data]
WHERE
	year(DateApproved)=2020 
GROUP BY year(DateApproved)

union

SELECT 
	count (distinct OriginatingLender) as OriginatingLender,
	year(DateApproved) as year_approved,
	count(LoanNumber) as Number_of_Approved,
	sum(InitialApprovalAmount) as Approved_Amount,
	avg(InitialApprovalAmount) as Average_loan_size
FROM [Projects].[dbo].[sba_public_data]
WHERE
	year(DateApproved)=2021
GROUP BY year(DateApproved)

--- Top 15 originating lenders by loan count, total amount and average in 2020-2021
 SELECT top 15
	OriginatingLender,
	count(LoanNumber) as Number_of_Approved,
	sum(InitialApprovalAmount) as Approved_Amount,
	avg(InitialApprovalAmount) as Average_loan_size
FROM [Projects].[dbo].[sba_public_data]
WHERE
	year(DateApproved)=2020
GROUP BY OriginatingLender
ORDER BY 3 DESC

SELECT top 15
	OriginatingLender,
	count(LoanNumber) as Number_of_Approved,
	sum(InitialApprovalAmount) as Approved_Amount,
	avg(InitialApprovalAmount) as Average_loan_size
FROM [Projects].[dbo].[sba_public_data]
WHERE
	year(DateApproved)=2021
GROUP BY OriginatingLender
ORDER BY 3 DESC

--Top 20 industries received the PPP Loans in 2021 and 2020

;with cte as
 (
	SELECT top 20
		d.Sector,
		count(LoanNumber) as Number_of_Approved,
		sum(InitialApprovalAmount) as Approved_Amount,
		avg(InitialApprovalAmount) as Average_loan_size
	FROM [Projects].[dbo].[sba_public_data] p
		INNER JOIN [dbo].[sba_naics_sector_codes_description] d
		ON LEFT(p.NAICSCode,2) = d.LookupCodes
	WHERE
		year(DateApproved)=2020
	GROUP BY d.Sector
	)

Select Sector, Number_of_Approved, Approved_Amount, Average_loan_size,
Approved_Amount/sum(Approved_Amount) OVER() * 100 Percent_by_Amount
FROM CTE
ORDER BY 3 DESC


;with cte as
 (
	 SELECT top 20
		d.Sector,
		count(LoanNumber) as Number_of_Approved,
		sum(InitialApprovalAmount) as Approved_Amount,
		avg(InitialApprovalAmount) as Average_loan_size
	FROM [Projects].[dbo].[sba_public_data] p
		INNER JOIN [dbo].[sba_naics_sector_codes_description] d
		ON LEFT(p.NAICSCode,2) = d.LookupCodes
	WHERE
		year(DateApproved)=2021
	GROUP BY d.Sector
	--ORDER BY 3 DESC
)
Select Sector, Number_of_Approved, Approved_Amount, Average_loan_size,
Approved_Amount/sum(Approved_Amount) OVER() * 100 Percent_by_Amount
FROM CTE
ORDER BY 3 DESC


---How much of the PPP Loans of 2021 have been fully forgiven
SELECT 
	count(LoanNumber) as Number_of_Approved,
	sum(CurrentApprovalAmount) as Current_Approved_Amount,
	avg(CurrentApprovalAmount) as Current_Average_loan_size,
	sum(ForgivenessAmount) as Amount_Forgiven,
	sum(ForgivenessAmount)/sum(CurrentApprovalAmount)*100 as percent_Forgiven
FROM 
	[Projects].[dbo].[sba_public_data]
WHERE
	year(DateApproved)=2021
ORDER BY 3 DESC

--- Year & Month with highest PPP loans approved

SELECT
	year(DateApproved) Year_Approved,
	month(DateApproved) Month_Approved,
	count(LoanNumber) Number_of_approbed,
	sum(InitialApprovalAmount) Total_Net_Dollars,
	avg(InitialApprovalAmount) Average_loan_size
FROM 
	[Projects].[dbo].[sba_public_data]
GROUP BY
	year(DateApproved),
	month(DateApproved) 
ORDER BY 
	4 DESC