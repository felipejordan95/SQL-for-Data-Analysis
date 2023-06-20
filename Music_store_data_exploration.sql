--Q1: Who is the senior most employee based on job title?
SELECT *
FROM employee
ORDER BY levels DESC
LIMIT 1;

--Q2: Which countries have the most invoices
SELECT billing_country country, count(*) num_invoice
FROM invoice
GROUP BY 1
ORDER BY 2 DESC

--Q3: What are top 3 values of total invoice
SELECT *
FROM invoice
ORDER BY total DESC
LIMIT 3

--Q4: Which city has the best customers? Write a query that returns on city that has the highest sum
--invoice totals. Return both the city name & sum of all invoice totals

SELECT billing_city city, sum(total) invoices_total
FROM invoice
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

--Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer.
--Write a query that returns the person who has spent the most money.
SELECT c.first_name, c.last_name, sum(i.total) total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1;

--Q6: Write a query to return the email, first name, last name & genre of all rock music listeners. 
--Return your list ordered ASC by email
SELECT DISTINCT c.email, c.first_name, c.Last_name
FROM customer c
JOIN invoice i ON c.customer_id=i.customer_id
JOIN invoice_line il ON i.invoice_id=il.invoice_id
JOIN track t ON il.track_id=t.track_id
JOIN genre g ON g.genre_id=t.genre_id

WHERE g.name LIKE 'Rock'
ORDER BY 1

--Q7: Let's invite the artists who have written the most rock music in our dataset. Write a query that 
--returns the Artist name and total track count of the top 10 rock bands.

SELECT a.artist_id, a.name, COUNT(a.artist_id) num_songs
FROM artist a
JOIN album al ON a.artist_id= al.artist_id
JOIN track t ON al.album_id=t.album_id
JOIN genre g ON g.genre_id=t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;

--Q8: Return all the track names that have a song length longer than the average son length. Return the Name
--and Miliseconds for each track. Order by the song length with the longest songs listed first.
SELECT name song_name, milliseconds duration
FROM track
WHERE milliseconds >
(SELECT AVG(milliseconds) avg_duration
FROM track)
ORDER BY 2 DESC

--Q9: Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent
SELECT c.first_name ||' '|| c.last_name customer_name,a.name artist_name, sum (il.unit_price*il.quantity) total_spent
FROM customer c
JOIN invoice i ON c.customer_id=i.customer_id
JOIN invoice_line il ON il.invoice_id= i.invoice_id
JOIN track t ON t.track_id=il.track_id
JOIN album al ON al.album_id=t.album_id
JOIN artist a ON a.artist_id=al.artist_id

GROUP BY 1,2
ORDER BY 2

--Q10: We want to find put the most popular music genre for each country. We determine the most popular genre as th genre with 
--the hightest amount of purchase. Write a query that returns each country along with the top genre. For countries where the
-- max number of purchases return all genres.

WITH popular_genre AS 
(
	SELECT COUNT(il.quantity) as purchases, c.country, g.name,g.genre_id,
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity)DESC) AS RowNo
	FROM invoice_line il
	JOIN invoice i ON il.invoice_id=i.invoice_id
	JOIN customer c ON c.customer_id=i.customer_id
	JOIN track t ON t.track_id=il.track_id
	JOIN genre g ON g.genre_id=t.genre_id
	GROUP BY 2,3,4
	ORDER BY 2,1 DESC
)

SELECT * FROM popular_genre WHERE RowNo <=1

--Q11: Write a query that determines the customer that has spent  the most on music for each country. Write a query 
--that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared,
--provide all customers who spent this amount

--Option 1
WITH 	customer_by_country AS(
		SELECT c.customer_id,c.first_name||' '||c.last_name customer_name, i.billing_country, SUM(i.total) total_spent
		FROM invoice i
		JOIN customer c ON i.customer_id=c.customer_id
		GROUP BY 1,2,3
		ORDER BY 3,4 DESC),
		
	country_max_spent AS (
	SELECT billing_country, MAX(total_spent) max_spent
	FROM customer_by_country
	GROUP BY 1)

SELECT cc.billing_country,cc.total_spent,cc.customer_name
FROM customer_by_country cc
JOIN country_max_spent ms ON cc.billing_country=ms.billing_country
WHERE cc.total_spent = ms.max_spent
ORDER BY 1;

--Option2

WITH customer_by_country AS(
		SELECT c.customer_id,c.first_name||' '||c.last_name customer_name, i.billing_country, SUM(i.total) total_spent,
		ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY sum(i.total)DESC) AS RowNo	
		FROM invoice i
		JOIN customer c ON i.customer_id=c.customer_id
		GROUP BY 1,2,3
		ORDER BY 3,4 DESC)
		
 SELECT * FROM customer_by_country WHERE RowNo <=1;