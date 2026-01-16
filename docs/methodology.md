# 📚 Metodología - NeoScore

## 1. Objetivos del Proyecto

### Objetivo Principal
Desarrollar un modelo de scoring crediticio alternativo que evalúe el riesgo de crédito basándose exclusivamente en el comportamiento transaccional bancario.

### Objetivos Específicos
1. Identificar patrones transaccionales asociados a riesgo crediticio
2. Crear features predictivas a partir de datos transaccionales
3. Entrenar y validar modelos de machine learning
4. Documentar el proceso para replicabilidad

## 2. Datos y Preprocesamiento

### Fuente de Datos
- Dataset de transacciones bancarias (~1M registros)
- Variables: ID transacción, cliente, fecha nacimiento, género, ubicación, balance, fecha/hora transacción, monto

### Limpieza de Datos
- Sanitización de nombres de columnas
- Tratamiento de fechas inválidas (1/1/1800)
- Gestión de valores nulos sin sesgo

### Feature Engineering
- Métricas de gasto (total, promedio, máximo, mínimo, desviación)
- Métricas de balance (promedio, mínimo, máximo)
- Métricas de actividad (frecuencia, días activos)
- Ratios derivados (gasto/balance, volatilidad)

## 3. Modelado

### Modelos a Evaluar
1. **Regresión Logística** - Baseline interpretable
2. **Random Forest** - Ensemble robusto
3. **XGBoost** - Estado del arte en tabular

### Validación
- Cross-validation estratificado (5-fold)
- Hold-out test set (20%)

## 4. Métricas de Evaluación

| Métrica | Descripción | Objetivo |
|---------|-------------|----------|
| **ROC-AUC** | Área bajo curva ROC | > 0.75 |
| **Gini** | 2 * AUC - 1 | > 0.50 |
| **KS Statistic** | Máxima separación | > 0.40 |
| **Precision@K** | Precisión en top K% | > 0.60 |

## 5. Consideraciones Éticas

- No usar género directamente en el modelo (evitar discriminación)
- Documentar posibles sesgos del dataset
- Transparencia en criterios de scoring
