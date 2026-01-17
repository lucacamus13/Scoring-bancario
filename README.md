# 🏦 NeoScore - Behavioral Credit Scoring

Sistema de scoring crediticio alternativo basado en **comportamiento transaccional**, no en saldo bancario.

## 🎯 Objetivo

Predecir el riesgo crediticio de clientes usando **únicamente su comportamiento de gasto**, sin depender del saldo en cuenta. Esto permite evaluar clientes nuevos sin historial de balance.

## ⚠️ Problema Resuelto: Data Leakage

Los modelos tradicionales usan el saldo (`avg_balance`) para predecir riesgo. Pero si el riesgo se define como `avg_balance < avg_spend`, el modelo "hace trampa" porque ya tiene la respuesta en los datos.

**Nuestra solución**: Eliminar todas las variables de balance y usar solo comportamiento.

## 📊 Resultados del Modelo

| Modelo | ROC-AUC | Gini | KS |
|--------|---------|------|-----|
| Logistic Regression | 0.6520 | 0.3039 | 0.2006 |
| Random Forest | 0.6613 | 0.3227 | 0.2154 |
| **XGBoost** 🏆 | **0.6640** | **0.3280** | **0.2206** |

> ✅ AUC ~0.66 es un resultado **honesto y realista** para un modelo sin acceso al saldo.

## 🔧 Stack Tecnológico

- **Almacenamiento**: Google BigQuery
- **Procesamiento**: Python (Google Colab)
- **ML**: Scikit-learn, XGBoost

## 📁 Estructura del Proyecto

```
NeoScore/
├── notebooks/
│   ├── limpieza-y-carga-a-query.ipynb  # ETL: CSV → BigQuery
│   ├── 03_eda.ipynb                     # Análisis Exploratorio
│   ├── 04_modeling.ipynb                # Modelos con balance (leakage)
│   └── 05_behavioral_scoring.ipynb      # ⭐ Modelo final (honesto)
├── sql/
│   ├── 01_data_verification.sql         # Verificación de datos
│   └── 02_customer_features.sql         # Feature engineering
├── src/
│   └── data_cleaning.py                 # Funciones de limpieza
├── data/
│   └── data_dictionary.md               # Diccionario de datos
└── docs/
    └── methodology.md                   # Metodología
```

## 🧠 Variables del Modelo Behavioral

**EXCLUIDAS** (causan leakage):
- `avg_balance`, `min_balance`, `max_balance`, `last_balance`
- `spend_to_balance_ratio`

**INCLUIDAS** (solo comportamiento):
| Variable | Descripción |
|----------|-------------|
| `age` | Edad del cliente |
| `spending_volatility` | Variabilidad del gasto (std/avg) |
| `transaction_density` | Transacciones por día activo |
| `spending_consistency` | Regularidad de compras |
| `avg_transaction_size` | Tamaño promedio de compra |
| `total_transactions` | Total de transacciones |
| `days_active` | Días con actividad |

## 🚀 Cómo Ejecutar

1. **Cargar datos a BigQuery**:
   - Ejecutar `notebooks/limpieza-y-carga-a-query.ipynb` en Colab
   - Esto crea la tabla `scoring_transacciones`

2. **Crear features**:
   - Ejecutar `sql/02_customer_features.sql` en BigQuery
   - Esto crea la tabla `customer_features`

3. **Entrenar modelo**:
   - Ejecutar `notebooks/05_behavioral_scoring.ipynb` en Colab
   - Obtener predicciones de riesgo

## 📈 Ejemplo de Uso

```python
# Juan: cliente con comportamiento estable
juan = {
    'age': 35,
    'spending_volatility': 0.40,  # Bajo (estable)
    'transaction_density': 1.5,   # Alto (frecuente)
    'spending_consistency': 0.80  # Alto (regular)
}
# Resultado: Probabilidad de riesgo = 23% → BAJO RIESGO ✅

# María: cliente con comportamiento errático
maria = {
    'age': 28,
    'spending_volatility': 2.5,   # Alto (errático)
    'transaction_density': 0.3,   # Bajo (esporádico)
    'spending_consistency': 0.30  # Bajo (irregular)
}
# Resultado: Probabilidad de riesgo = 78% → ALTO RIESGO ❌
```

## 👤 Autor

**Luca Camus** - Economista | Data Scientist

---

*Proyecto desarrollado como parte del aprendizaje de Machine Learning aplicado a finanzas.*
