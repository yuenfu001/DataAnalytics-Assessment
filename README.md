## Assessment_Q1 - High-Value Customers with Both Savings and Investments

### ✅ Objective
Identify users who:
- Have **at least one savings plan**.
- Have **at least one investment plan**.
- Show their **total confirmed deposits** (from `savings_savingsaccount`).

### 💡 Approach
1. From `users_customuser`, generated each user’s full name.
2. From `plans_plan`, filtered customers with both `is_regular_savings = 1` and `is_a_fund = 1`.
3. From `savings_savingsaccount`, calculated total confirmed deposits (divided by 100.0 to adjust for currency scaling).
4. Joined the three datasets and sorted customers by highest total deposits.

### ⚠️ Challenges
- Ensured accurate grouping and filtering using `HAVING` after aggregation.
- Data joins had to be clean since some customers may not have deposits despite having plans.
- `confirmed_amount` stored in smallest currency unit (e.g., Kobo or Cent), required division by 100.

### 🛠 Notes
- Used `ROUND(..., 2)` to clean up deposit values for reporting.
- `HAVING savings > 0 AND investment > 0` ensured only dual-plan customers were considered.


## Assessment_Q2 - Transaction Frequency Analysis

### ✅ Objective
To categorize customers based on how frequently they transact on average per month:
- High Frequency (≥ 10 txns/month)
- Medium Frequency (3-9 txns/month)
- Low Frequency (≤ 2 txns/month)

### 💡 Approach
1. Extracted **monthly successful transactions per customer** using `DATE_FORMAT(transaction_date, '%Y-%m')`.
2. Calculated each customer's **average transactions per month** using `AVG()`.
3. Applied business logic to categorize customers into three frequency tiers.
4. Aggregated results to count customers in each frequency tier and compute their average monthly transaction volumes.

### ⚠️ Challenges
- Original query aggregated by **daily transactions**, which gave misleading frequency data.
- Proper frequency analysis required grouping by **year-month** instead of raw `transaction_date`.
- Care was needed to handle users with few monthly records correctly in averages.

### 🛠 Notes
- Only **successful transactions** (`transaction_status LIKE '%suc%'`) were considered.
- Used Common Table Expressions (CTEs) for readability and logical breakdown of steps.


## Assessment_Q3 - Account Inactivity Alert

### ✅ Objective
Identify active Savings or Investment accounts with no inflow transactions for more than 365 days. This helps the ops team detect long-term inactive users.

### 💡 Approach
1. Queried the `savings_savingsaccount` table to:
   - Get each customer's **last transaction date**.
   - Extract the **current system-wide latest transaction date** as reference (`currentdate`).
2. Joined this data with the `plans_plan` table to filter for **active account types**:
   - Savings (`is_regular_savings = 1`)
   - Investment (`is_a_fund = 1` or `is_fixed_investment = 1`)
3. Used `DATEDIFF()` to calculate inactivity duration.
4. Applied a filter for `inactivity_days > 365`.

### ⚠️ Challenges
- Interpreting the correct plan type from multiple flags (`is_a_fund`, `is_fixed_investment`, `is_regular_savings`).
- Avoiding false positives by excluding non-standard account types (labeled as `Other`).
- Making sure customers with multiple plan types were still matched to the correct transaction history.

### 🛠 Notes
- The `last_transaction_date` was derived from savings inflows (`savings_savingsaccount`).
- Assumed all transaction inflows are recorded under `savings_savingsaccount`.




## Assessment_Q4. Customer Lifetime Value (CLV) Estimation

### 💡 Approach
1. **Joined `users_customuser` with `savings_savingsaccount`** to link customers with their transactions.
2. **Filtered only successful transactions** using a `LIKE '%succ%'` condition.
3. **Converted transaction value from kobo to naira** and applied 0.1% to get estimated profit.
4. **Used CTE** to calculate intermediate values (tenure, total profit, total transactions).
5. Final SELECT computed CLV using the given formula and sorted customers in descending order of CLV.

### ⚠️ Challenges
- Handling monetary unit conversion from kobo to naira and ensuring proper percentage calculation.
- Accurately calculating the tenure using `TIMESTAMPDIFF` and aligning it with transaction dates.

### 🛠 Notes
- Only inflow transactions (confirmed deposits) were considered.
- Profit per transaction was assumed consistent across the board (0.1%).

