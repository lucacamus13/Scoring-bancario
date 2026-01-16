-- ==============================================================================
-- NeoScore - Verificación de datos cargados
-- ==============================================================================

-- 1. Verificar carga de datos
SELECT 
    COUNT(*) as total_rows,
    COUNT(DISTINCT customerid) as unique_customers,
    MIN(transactiondate) as first_date,
    MAX(transactiondate) as last_date,
    AVG(transactionamount) as avg_amount
FROM `scoring-bancario.analisis_bancario.scoring_transacciones`;

-- 2. Verificar limpieza de fechas zombi
SELECT COUNT(*) as zombie_dates
FROM `scoring-bancario.analisis_bancario.scoring_transacciones`
WHERE customerdob = DATE '1800-01-01';
-- Esperado: 0

-- 3. Distribución de género
SELECT 
    custgender,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM `scoring-bancario.analisis_bancario.scoring_transacciones`
GROUP BY custgender;

-- 4. Top 10 ciudades
SELECT 
    custlocation,
    COUNT(*) as transactions
FROM `scoring-bancario.analisis_bancario.scoring_transacciones`
GROUP BY custlocation
ORDER BY transactions DESC
LIMIT 10;
