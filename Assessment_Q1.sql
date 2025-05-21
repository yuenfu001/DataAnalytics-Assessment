-- Q1: Identify customers who have at least one savings plan and one investment plan, and show their total deposits.

-- Final selection with customer full name, count of savings/investment plans, and total confirmed deposits
SELECT 
    pp.owner_id,
    uc.fullname AS name,
    pp.savings AS savings_count,
    pp.investment AS investment_count,
    ssa.total_deposits
FROM (
    -- Step 1: Get user ID and full name
    SELECT 
        id, 
        CONCAT(first_name, ' ', last_name) AS fullname
    FROM users_customuser
) AS uc

-- Step 2: Join with customers who have at least one savings and one investment plan
JOIN (
    SELECT 
        owner_id, 
        SUM(CASE WHEN is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings,
        SUM(CASE WHEN is_a_fund = 1 THEN 1 ELSE 0 END) AS investment
    FROM plans_plan
    GROUP BY owner_id
    HAVING savings > 0 AND investment > 0
) AS pp ON uc.id = pp.owner_id

-- Step 3: Join with total deposits from savings_savingsaccount
JOIN (
    SELECT 
        owner_id, 
        ROUND(SUM(confirmed_amount) / 100.0, 2) AS total_deposits
    FROM savings_savingsaccount
    GROUP BY owner_id
) AS ssa ON uc.id = ssa.owner_id

-- Step 4: Sort by highest deposits
ORDER BY total_deposits DESC;
