USE assessment;

-- Q3: Account Inactivity Alert
-- Goal: Identify active accounts (Savings or Investment) with no transactions in the last 365 days

-- Step 1: Build a subquery to get the most recent transaction date per customer
-- Also fetch the overall latest transaction date as "currentdate" for inactivity calculation

SELECT DISTINCT 
    owner_id, 
    id AS plan_id, 
    type, 
    last_transaction_date, 
    currentdate,
    DATEDIFF(currentdate, last_transaction_date) AS inactivity_days
FROM (
    SELECT 
        pp.owner_id,
        pp.id,
        -- Use flags to determine the plan type
        CASE 
            WHEN is_a_fund = 1 THEN 'Investment'
            WHEN is_regular_savings = 1 THEN 'Savings'
            WHEN is_fixed_investment = 1 THEN 'Investment'
            ELSE 'Other'
        END AS type,
        sub.last_transaction_date,
        sub.currentdate
    FROM plans_plan pp
    JOIN (
        SELECT 
            owner_id, 
            MAX(transaction_date) AS last_transaction_date,
            -- Capture the most recent transaction across all accounts
            (SELECT MAX(transaction_date) FROM savings_savingsaccount) AS currentdate
        FROM savings_savingsaccount
        GROUP BY owner_id
    ) AS sub
    ON pp.owner_id = sub.owner_id
) AS T

-- Step 2: Filter for relevant account types
-- Ignore any "Other" (non-savings/investment) types
-- Only include accounts that have been inactive for more than 365 days

WHERE type != 'Other'
  AND DATEDIFF(currentdate, last_transaction_date) > 365;


SELECT *
FROM savings_savingsaccount
LIMIT 5;
