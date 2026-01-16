-- ==============================================================================
-- NeoScore - Customer Features Table
-- ==============================================================================
-- Descripción: Tabla maestra de características por cliente para scoring
-- Proyecto: scoring-bancario
-- Dataset: analisis_bancario
-- ==============================================================================

CREATE OR REPLACE TABLE `scoring-bancario.analisis_bancario.customer_features` AS

WITH customer_base AS (
    SELECT 
        customerid,
        MAX(customerdob) AS dob,
        MAX(custgender) AS gender,
        ARRAY_AGG(custlocation ORDER BY transactiondate DESC LIMIT 1)[OFFSET(0)] AS location,
        ARRAY_AGG(custaccountbalance ORDER BY transactiondate DESC LIMIT 1)[OFFSET(0)] AS last_balance
    FROM `scoring-bancario.analisis_bancario.scoring_transacciones`
    GROUP BY customerid
),

customer_transactions AS (
    SELECT 
        customerid,
        COUNT(*) AS total_transactions,
        SUM(transactionamount) AS total_spend,
        AVG(transactionamount) AS avg_spend,
        MAX(transactionamount) AS max_spend,
        MIN(transactionamount) AS min_spend,
        -- COALESCE: Si solo 1 transacción, STDDEV es NULL → usamos 0 (sin variación)
        COALESCE(STDDEV(transactionamount), 0) AS std_spend,
        AVG(custaccountbalance) AS avg_balance,
        MIN(custaccountbalance) AS min_balance,
        MAX(custaccountbalance) AS max_balance,
        MIN(transactiondate) AS first_transaction_date,
        MAX(transactiondate) AS last_transaction_date,
        DATE_DIFF(MAX(transactiondate), MIN(transactiondate), DAY) AS days_active,
        COUNT(DISTINCT transactiondate) AS unique_transaction_days,
        AVG(CAST(SUBSTR(CAST(transactiontime AS STRING), 1, 2) AS INT64)) AS avg_transaction_hour
    FROM `scoring-bancario.analisis_bancario.scoring_transacciones`
    GROUP BY customerid
)

SELECT 
    b.customerid,
    b.dob,
    CASE 
        WHEN b.dob IS NULL THEN NULL
        ELSE DATE_DIFF(CURRENT_DATE(), b.dob, YEAR)
    END AS age,
    b.gender,
    b.location,
    b.last_balance,
    t.avg_balance,
    t.min_balance,
    t.max_balance,
    t.total_spend,
    t.avg_spend,
    t.max_spend,
    t.min_spend,
    t.std_spend,
    -- Flag: 1 si el cliente tiene suficientes transacciones para calcular volatilidad
    CASE WHEN t.total_transactions > 1 THEN 1 ELSE 0 END AS has_volatility_data,
    t.total_transactions,
    t.first_transaction_date,
    t.last_transaction_date,
    t.days_active,
    t.unique_transaction_days,
    SAFE_DIVIDE(t.total_transactions, t.unique_transaction_days) AS transaction_frequency,
    SAFE_DIVIDE(t.avg_spend, t.avg_balance) AS spend_to_balance_ratio,
    -- Volatilidad: si std_spend es 0 (1 transacción), volatilidad = 0
    COALESCE(SAFE_DIVIDE(t.std_spend, t.avg_spend), 0) AS spend_volatility,
    SAFE_DIVIDE(t.total_transactions, GREATEST(t.days_active, 1)) AS avg_daily_transactions,
    SAFE_DIVIDE(t.total_spend, GREATEST(t.days_active, 1)) AS avg_daily_spend,
    
    -- Flag de riesgo: HighRisk = 1 si AvgBalance < AvgSpend
    CASE 
        WHEN t.avg_balance < t.avg_spend THEN 1
        ELSE 0
    END AS high_risk_flag,
    
    -- Score preliminar 0-100
    ROUND(
        (CASE 
            WHEN t.avg_balance >= t.avg_spend * 3 THEN 40
            WHEN t.avg_balance >= t.avg_spend * 2 THEN 30
            WHEN t.avg_balance >= t.avg_spend THEN 20
            WHEN t.avg_balance >= t.avg_spend * 0.5 THEN 10
            ELSE 0
        END)
        +
        (CASE 
            WHEN t.total_transactions >= 100 THEN 30
            WHEN t.total_transactions >= 50 THEN 25
            WHEN t.total_transactions >= 20 THEN 20
            WHEN t.total_transactions >= 10 THEN 15
            ELSE 10
        END)
        +
        -- Componente estabilidad: volatilidad 0 (1 trans) = máxima estabilidad
        (CASE 
            WHEN COALESCE(SAFE_DIVIDE(t.std_spend, t.avg_spend), 0) < 0.5 THEN 30
            WHEN COALESCE(SAFE_DIVIDE(t.std_spend, t.avg_spend), 0) < 1 THEN 25
            WHEN COALESCE(SAFE_DIVIDE(t.std_spend, t.avg_spend), 0) < 1.5 THEN 20
            WHEN COALESCE(SAFE_DIVIDE(t.std_spend, t.avg_spend), 0) < 2 THEN 15
            ELSE 10
        END)
    , 0) AS preliminary_credit_score,
    
    CURRENT_TIMESTAMP() AS created_at

FROM customer_base b
JOIN customer_transactions t ON b.customerid = t.customerid;
