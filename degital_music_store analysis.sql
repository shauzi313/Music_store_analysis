--1. Who is the most senior employee based on the job title? 
select first_name, last_name, employee_id, title 
from employee 
order by levels desc 
limit 1

--2. Which countries have the most invoices? 
select billing_country, count(total) as total  
from invoice 
group by billing_country 
order by total desc 
limit 5

--3. What are top 3 values of most invoices? 
select billing_country, count(total) as total  
from invoice 
group by billing_country 
order by total desc 
limit 3

/*4. Which city has the best customers? We would like to throw a 
promotional Music Festival in the city we made the most money. Write a 
query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals 
*/
select c.city, sum(i.total) as total 
from customer as c 
join invoice as i 
on i.customer_id=c.customer_id 
group by city 
order by 2 desc 
limit 5

/*5. Who is the best customer? The customer who has spent the most 
money will be declared the best customer. Write a query that returns 
the person who has spent the most money. 
*/ 
select c.first_name, c.last_name, sum(i.total) as total 
from customer as c 
join invoice as i 
on i.customer_id=c.customer_id 
group by 1,2 
order by 3 desc 
limit 1 

/*6. Write query to return the email, first name, last name, & Genre of all 
Rock Music listeners. Return your list ordered alphabetically by email 
starting with A. 
*/
select c.email, c.first_name, c.last_name 
from customer as c 
join invoice as i 
on i.customer_id=c.customer_id 
join invoice_line il 
on il.invoice_id=i.invoice_id 
join track as t 
on t.track_id=il.track_id 
join genre as g 
on g.genre_id=t.genre_id 
where g.name='Rock' 
group by c.first_name, c.last_name, c.email 
order by c.email 
limit 17;

/*7. Let's invite the artists who have written the most rock music in our 
dataset. Write a query that returns the Artist name and total track count 
of the top 10 rock bands. 
*/ 
select a.name, count(g.genre_id) as total_songs 
from artist as a 
join album as ab 
on ab.artist_id=a.artist_id 
join track as t 
on t.album_id=ab.album_id 
join genre as g 
on g.genre_id=t.genre_id 
where g.name='Rock' 
group by a.name 
order by 2 desc 
limit 10

/*8. Return all the track names that have a song length longer than the 
average song length. Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first.
*/
select name, milliseconds 
from track 
where milliseconds>(select avg(milliseconds) as av from track) 
order by milliseconds desc

/*9. Find how much amount spent by each customer on artists? Write a 
query to return customer name, artist name and total spent
*/
with best_selling_artist as( 
select a.artist_id, a.name, sum(il.quantity*il.unit_price) as total_amount 
from invoice_line as il 
join track as t 
on t.track_id=il.track_id 
join album as al 
on al.album_id=t.album_id 
join artist as a 
on a.artist_id=al.artist_id 
group by a.artist_id 
order by total_amount desc 
limit 1 
) 
select 
c.first_name, 
sum(il.quantity*il.unit_price) as total_amount 
from customer as c 
join invoice as i 
on i.customer_id=c.customer_id 
join invoice_line as il 
on il.invoice_id=i.invoice_id 
join track as t 
on t.track_id=il.track_id 
join album as al 
on al.album_id=t.album_id 
join best_selling_artist as bsa 
on bsa.artist_id=al.artist_id 
group by 1,2,3 
order by 4 desc

/*10. We want to find out the most popular music Genre for each country. We 
determine the most popular genre as the genre with the highest amount 
of purchases. Write a query that returns each country along with the top 
Genre. For countries where the maximum number of purchases is 
shared return all Gen 
*/
with best_selling_genre as ( 
select count(il.quantity) as purchased, c.country, g.name, 
g.genre_id, row_number() over(partition by c.country order by 
count(il.quantity) desc) as rowno 
from customer as c 
join invoice as i 
on i.customer_id=c.customer_id 
join invoice_line as il 
on il.invoice_id=i.invoice_id 
join track as t 
on t.track_id=il.track_id 
join genre as g 
on g.genre_id=t.genre_id 
group by 2,3,4 
order by 2 asc, 1 desc 
) 
select country, name, purchased 
from best_selling_genre as bsg 
where bsg.rowno=1 
order by purchased desc 

/*11. Write a query that determines the customer that has spent the most on 
music for each country. Write a query that returns the country along 
with the top customer and how much they spent. For countries where 
the top amount spent is shared, provide all customers who spent this 
amount. 
*/
with customer_with_country as( 
select c.customer_id, c.first_name, c.last_name, i.billing_country, 
sum(i.total) as amount, 
row_number() over(partition by i.billing_country order by sum(i.total) 
desc) as rono 
from invoice as i 
join customer as c 
on c.customer_id=i.customer_id 
group by 1,2,3,4 
order by 4 asc, 5 desc 
) 
select customer_id, first_name, last_name, billing_country, amount 
from customer_with_country  
where rono=1 
order by 5 desc






