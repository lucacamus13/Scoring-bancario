# 📊 Diccionario de Datos - NeoScore

## Dataset Original: bank_transactions.csv

| Campo | Tipo | Descripción | Problemas Identificados |
|-------|------|-------------|------------------------|
| `TransactionID` | String | Identificador único de transacción | ✅ Limpio |
| `CustomerID` | String | Identificador único de cliente | ✅ Limpio |
| `CustomerDOB` | Date | Fecha de nacimiento del cliente | ⚠️ Fechas "1/1/1800" y "nan" |
| `CustGender` | String | Género (M/F) | ⚠️ Valores nulos |
| `CustLocation` | String | Ciudad/Ubicación | ✅ Limpio |
| `CustAccountBalance` | Float | Balance en cuenta (INR) | ⚠️ Algunos vacíos |
| `TransactionDate` | Date | Fecha de transacción | ✅ Formato dd/mm/yy |
| `TransactionTime` | Int | Hora de transacción | ✅ Formato HHMMSS |
| `TransactionAmount (INR)` | Float | Monto de transacción | ⚠️ Nombre con paréntesis |

## Estadísticas del Dataset

- **Total de registros**: ~1,048,567
- **Período**: 2016
- **Moneda**: INR (Rupia India)

## Transformaciones Aplicadas

1. Nombres de columnas → snake_case
2. Fechas zombi (1/1/1800) → NULL
3. Fechas de nacimiento → Formato DATE
4. Corrección de años (94 → 1994, no 2094)

## Tabla: customer_features (BigQuery)

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `customerid` | STRING | ID único del cliente |
| `age` | INT | Edad calculada |
| `gender` | STRING | Género (M/F/NULL) |
| `total_spend` | FLOAT | Gasto total en período |
| `avg_balance` | FLOAT | Balance promedio |
| `high_risk_flag` | INT | 1 si AvgBalance < AvgSpend |
| `preliminary_credit_score` | INT | Score 0-100 |
