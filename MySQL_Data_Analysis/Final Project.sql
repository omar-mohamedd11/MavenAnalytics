-- FInal Project

-- Q1 store manager's name, address (street, district, city, country)

select
	store.store_id,
	first_name, last_name,
	address, district,
	city, country
from store
join staff
	on staff.staff_id = store.manager_staff_id
join address
	on address.address_id = staff.staff_id
join city
	on city.city_id = address.city_id
join country
	on country.country_id = city.country_id;
    
/* Q2 Inventory details (inventory id , store id, film title, 
   film's rating , rental rate, rental RC) */

select 
	inventory_id, store_id,
    title, rating,
    rental_rate, Replacement_cost
from inventory
join film
	on film.film_id = inventory.film_id;
    
-- Q3 How many inventory itemes we have for each rating per store

select 
	store_id,
    count(case when rating = 'PG' then rating end) PG,
    count(case when rating = 'G' then rating end) G,
    count(case when rating = 'NC-17' then rating end) 'NC-17',
    count(case when rating = 'PG-13' then rating end) 'PG-13',
    count(case when rating = 'R' then rating end) R
from inventory
join film
	on film.film_id = inventory.film_id
group by 1;

-- Q4 the number of films, average RC, total RC, sliced by Rating and store

select 
	category.name, store_id,
    count(rating) Number_of_films,
    round(avg(Replacement_cost),2) Average_RC,
    sum(replacement_cost) Total_RC
from inventory
join film
	on film.film_id = inventory.film_id
join film_category
	on film_category.film_id = film.film_id
join category
	on category.category_id = film_category.category_id
group by 1,2
order by 2;
/* Q5 Customer names,which store they go to
active or not, street address, city, country
*/

select 
	first_name, Last_name, store_id,
	case when `active` = 1 then 'Yes'
		 else 'No' end as Activity,
	address, district,
    city, country
from customer
join address
	on address.address_id = customer.address_id
join city
	on city.city_id = address.city_id
join country
	on country.country_id = city.country_id;
    
/* Q6 A list of customer names, total lifetime rentals,
	sum of all payments */
select 
	customer.first_name, customer.last_name,
    count(rental.rental_id) total_rentals,
    sum(amount) total_payments
from customer 
join rental
	on rental.customer_id = customer.customer_id
join payment
	on payment.rental_id = rental.rental_id
group by 1,2
order by 4 desc;

-- Q7 A list of advisors and investors(and their company)

select 
	first_name,last_name,
    'Investor', company_name
from investor
union all
select 
	first_name, Last_name,
    'Advisor', ' '
from advisor;

-- Q8

SELECT
 CASE 
 WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
 WHEN actor_award.awards IN ('Emmy, Oscar','Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
 ELSE '1 award'
 END AS number_of_awards, 
 AVG(CASE WHEN actor_award.actor_id IS NULL THEN 0 ELSE 1 END) AS Percentage
 
FROM actor_award
GROUP BY 1
;

