-- view savings table
SELECT *
FROM savings_savingsaccount
LIMIT 5;

DESCRIBE savings_savingsaccount;

SELECT COUNT(*)
FROM savings_savingsaccount
WHERE transaction_status LIKE '%succ%';

WITH CTE AS (
	SELECT transaction_date, customer_count, SUM(transaction_count) as total_transaction,
CASE 
	WHEN AVG(transaction_count)<3 THEN 'Low Frequency'
		WHEN AVG(transaction_count)>2 AND AVG(transaction_count) <10 THEN 'Medium Frequency'
			WHEN AVG(transaction_count)>9 THEN 'High Frequency'
END AS frequency_category
FROM (
	SELECT transaction_date, COUNT(owner_id) as customer_count, COUNT(transaction_status) as transaction_count
FROM savings_savingsaccount
WHERE transaction_status LIKE '%suc%'
GROUP BY transaction_date
) AS T
GROUP BY transaction_date
)

SELECT frequency_category, SUM(customer_count) AS customer_count, ROUND(AVG(total_transaction),1) AS avg_transactions_per_month
FROM CTE
GROUP BY frequency_category;



