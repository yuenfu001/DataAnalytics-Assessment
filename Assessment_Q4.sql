SELECT *
FROM users_customuser
LIMIT 5;

SELECT *
FROM savings_savingsaccount
LIMIT 5;


DESCRIBE users_customuser;
-- GET customer fullname and id

-- Q4: Customer Lifetime Value (CLV) Estimation
-- Goal: Estimate CLV using tenure and transaction value

-- Step 1: CTE to prepare data by calculating:
-- a) Customer tenure in months
-- b) Total number of successful transactions
-- c) Total profit from transactions (0.1% of value, converted from kobo to naira)

WITH CTE AS (
    SELECT 
        uc.id AS customer_id,
        CONCAT(uc.first_name, ' ', uc.last_name) AS name,
        TIMESTAMPDIFF(MONTH, uc.date_joined, (
            -- Get latest transaction date across all customers
            SELECT MAX(transaction_date) 
            FROM savings_savingsaccount
        )) AS tenure_months,
        ssa.total_transactions,
        ssa.total_transaction_profit
    FROM users_customuser uc
    JOIN (
        SELECT 
            owner_id,
            COUNT(confirmed_amount) AS total_transactions,
            ROUND(SUM(confirmed_amount * 0.001) / 100, 1) AS total_transaction_profit -- Convert kobo to naira
        FROM savings_savingsaccount
        WHERE transaction_status LIKE '%succ%' -- Filter for successful transactions
        GROUP BY owner_id
    ) AS ssa
    ON uc.id = ssa.owner_id
)

-- Step 2: Calculate estimated CLV using the formula
-- CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction

SELECT 
    customer_id, 
    name, 
    tenure_months,
    total_transactions,
    ROUND(
        (total_transactions / tenure_months) * 12 * (total_transaction_profit / total_transactions), 
        1
    ) AS estimated_clv
FROM CTE
ORDER BY estimated_clv DESC;
