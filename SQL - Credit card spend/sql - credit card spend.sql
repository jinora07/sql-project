-- Q1. What is the average credit limit?

SELECT AVG(credit_limit) AS avg_credit_limit
FROM customer;


-- Q2. Which type of credit card is most commonly held by customers?

SELECT card_type, COUNT(*) AS frequency
FROM customer
GROUP BY card_type
ORDER BY count DESC
LIMIT 1;


-- Q3. What is the average age of credit card holders?

SELECT ROUND(AVG(age)) AS avg_age
FROM customer


-- Q4. What is the most common spending category?

SELECT product_type, COUNT(*) AS frequency
FROM spend
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- Q5. Show the month-wise spend across the years in descending order.

SELECT MONTHNAME(date) AS month, ROUND(SUM(amount)) AS amount_spend
FROM spend
GROUP BY month
ORDER BY amount_spend DESC;


-- Q6. What is the average spend per category?

SELECT product_type, ROUND(AVG(amount)) AS avg_spent
FROM spend
GROUP BY product_type
ORDER BY avg_spent DESC;


-- Q7. What is the average no. of transactions per month?

SELECT MONTHNAME(date) AS month, COUNT(*) AS transaction
FROM spend
GROUP BY month
ORDER BY transaction DESC;


-- Q8. List the top 5 cities with the highest amount spent along with their no. of transactions.

WITH top_customers AS (
SELECT customer_id, ROUND(SUM(amount)) AS amount, COUNT(*) AS transaction 
FROM spend
GROUP BY customer_id
ORDER BY amount DESC
)
SELECT city, SUM(amount) AS amount, SUM(transaction) AS transactions
FROM top_customers AS tc
JOIN customer ON customer.customer_id = tc.customer_id
GROUP BY 1
ORDER BY 2 DESC, 3 DESC
LIMIT 5;


-- Q9. List the card types and the amount spent with them over the years.

WITH cust AS (
SELECT customer_id, SUM(amount) AS amount
FROM spend
GROUP BY customer_id
ORDER BY amount DESC
)
SELECT card_type, ROUND(SUM(amount)) AS amount
FROM (SELECT cust.customer_id, card_type, amount
		FROM cust
		JOIN customer ON customer.customer_id = cust.customer_id) as cards
GROUP BY card_type
ORDER BY amount DESC;


-- Q10. Which is the most commonly used credit card type?

WITH cust AS (
SELECT customer_id, COUNT(*) AS transactions
FROM spend
GROUP BY customer_id
ORDER BY transactions DESC
)
SELECT card_type, SUM(transactions) AS transactions
FROM (SELECT cust.customer_id, card_type, transactions
		FROM cust
		JOIN customer ON customer.customer_id = cust.customer_id) as cards
GROUP BY card_type
ORDER BY transactions DESC;


-- Q11. What is the average no. of days a customer pays off their credit card bill?

WITH bill AS (
SELECT spend.customer_id, 
	MAX(spend.date) AS spend_date, 
	MAX(repayment.date) AS repayment_date, 
	ABS(DATEDIFF(MAX(repayment.date), MAX(spend.date))) AS days
FROM spend
JOIN customer ON customer.customer_id = spend.customer_id
JOIN repayment ON repayment.customer_id = customer.customer_id
GROUP BY 1
)
SELECT ROUND(AVG(days)) AS avg_days
FROM bill;


-- Q12. What is the rate of late-paying customers, assume the no. of days to pay off the bill is 30 days.

WITH bill AS (
SELECT spend.customer_id,
	MAX(spend.date) AS spend_date, 
	MAX(repayment.date) AS repayment_date, 
	ABS(DATEDIFF(MAX(repayment.date), 
	MAX(spend.date))) AS days
FROM spend
JOIN customer ON customer.customer_id = spend.customer_id
JOIN repayment ON repayment.customer_id = customer.customer_id
GROUP BY 1
)
SELECT CONCAT(ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM CUSTOMER)), '%') AS late_payment
FROM bill
WHERE days > 30;


-- Q13. Show the customer base city-wise in descending order.

SELECT city, COUNT(customer_id) AS customer
FROM customer 
GROUP BY city
ORDER BY customer DESC;


-- Q14. What is the spending range of each customer?

SELECT customer_id, CONCAT(MAX(amount), ' - ', MIN(amount)) AS spending_range
FROM spend
GROUP BY customer_id;
