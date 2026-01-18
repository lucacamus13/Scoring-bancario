# NeoScore: Alternative Credit Scoring Based on Transactional Behavior

**Autor:** Luca Camus  
**Fecha:** Enero 2026  
**Disciplina:** EconomÃ­a Aplicada | Machine Learning

---

## Resumen Ejecutivo

Este proyecto desarrolla un modelo de **scoring crediticio alternativo** que evalÃºa el riesgo de un cliente basÃ¡ndose exclusivamente en su **comportamiento transaccional**, sin utilizar informaciÃ³n sobre su saldo bancario. 

El enfoque tradicional de credit scoring depende fuertemente del balance en cuenta, lo cual presenta dos limitaciones: (1) no es aplicable a clientes nuevos sin historial de saldo, y (2) genera **data leakage** cuando el riesgo se define en funciÃ³n del propio saldo.

Nuestro modelo behavioral alcanza un **AUC de 0.664**, demostrando que los patrones de gasto contienen informaciÃ³n predictiva sobre el riesgo crediticio, independientemente del nivel de activos del cliente.

---

## 1. IntroducciÃ³n

### 1.1 Contexto EconÃ³mico

La evaluaciÃ³n del riesgo crediticio es fundamental para la estabilidad del sistema financiero. Tradicionalmente, los bancos utilizan el historial crediticio y el nivel de activos para determinar la solvencia de un cliente. Sin embargo, este enfoque excluye a segmentos importantes de la poblaciÃ³n:

- **Clientes nuevos** sin historial bancario (inclusiÃ³n financiera)
- **Trabajadores informales** con ingresos no documentados
- **JÃ³venes** que inician su vida financiera

### 1.2 Propuesta de Valor

NeoScore propone un paradigma diferente: en lugar de evaluar *cuÃ¡nto tiene* el cliente, evaluamos *cÃ³mo se comporta*. Esta perspectiva se alinea con la literatura econÃ³mica sobre preferencias reveladas (Samuelson, 1938): las decisiones de consumo observadas contienen informaciÃ³n sobre las preferencias y restricciones subyacentes del agente.

### 1.3 Objetivos

1. Desarrollar un modelo de Machine Learning que prediga riesgo crediticio usando solo variables de comportamiento
2. Identificar y eliminar el data leakage presente en modelos tradicionales
3. Producir un modelo "honesto" con mÃ©tricas realistas, aplicable en entornos productivos

---

## 2. Datos y MetodologÃ­a

### 2.1 Dataset

Se utilizÃ³ un dataset de transacciones bancarias con las siguientes caracterÃ­sticas:

| Atributo | Valor |
|----------|-------|
| Registros | ~1,048,567 transacciones |
| Clientes Ãºnicos | ~120,000 |
| PerÃ­odo | 2016-2017 |
| Variables | TransactionID, CustomerID, CustomerDOB, CustGender, CustLocation, CustAccountBalance, TransactionDate, TransactionTime, TransactionAmount |

### 2.2 Arquitectura de Datos

```
CSV (Local) â†’ Python (Limpieza) â†’ BigQuery (Almacenamiento) â†’ Python (Modelado)
```

**Stack tecnolÃ³gico:**
- **Google BigQuery**: Data warehouse para almacenamiento y feature engineering
- **Python (Google Colab)**: Limpieza, anÃ¡lisis y modelado
- **Scikit-learn / XGBoost**: Algoritmos de Machine Learning

### 2.3 Proceso de Limpieza

Se identificaron y corrigieron los siguientes problemas de calidad:

| Problema | SoluciÃ³n |
|----------|----------|
| Fechas "zombi" (01/01/1800) | Reemplazo por NULL (~5.8% de registros) |
| AÃ±os mal interpretados (94 â†’ 2094) | CorrecciÃ³n automÃ¡tica (-100 aÃ±os) |
| Nombres de columnas con caracteres especiales | SanitizaciÃ³n a snake_case |

### 2.4 Feature Engineering

Se crearon features a nivel cliente mediante agregaciones SQL en BigQuery:

**Variables de comportamiento (utilizadas):**

| Variable | FÃ³rmula | InterpretaciÃ³n EconÃ³mica |
|----------|---------|--------------------------|
| `spending_volatility` | Ïƒ(gasto) / Î¼(gasto) | Estabilidad del patrÃ³n de consumo |
| `transaction_density` | transacciones / dÃ­as_activos | Frecuencia de actividad econÃ³mica |
| `spending_consistency` | dÃ­as_Ãºnicos / dÃ­as_activos | Regularidad del comportamiento |
| `avg_transaction_size` | gasto_total / n_transacciones | Escala tÃ­pica de consumo |

**Variables excluidas (causan leakage):**

| Variable | RazÃ³n de exclusiÃ³n |
|----------|-------------------|
| `avg_balance` | CorrelaciÃ³n directa con definiciÃ³n de riesgo |
| `spend_to_balance_ratio` | Contiene informaciÃ³n del balance |
| `preliminary_credit_score` | Calculado usando balance |

---

## 3. El Problema del Data Leakage

### 3.1 DefiniciÃ³n del Problema

En el dataset, la variable objetivo se define como:

```
high_risk_flag = 1  si  avg_balance < avg_spend
high_risk_flag = 0  si  avg_balance â‰¥ avg_spend
```

Si incluimos `avg_balance` y `avg_spend` como features, el modelo puede reconstruir la regla exacta, obteniendo un AUC artificialmente alto (~0.99).

### 3.2 AnalogÃ­a EconÃ³mica

Es equivalente a predecir si una persona estÃ¡ en pobreza usando su ingreso como variable predictora cuando la definiciÃ³n de pobreza es precisamente "ingreso < lÃ­nea de pobreza". El modelo no aprende nada nuevo; simplemente reproduce la definiciÃ³n.

### 3.3 SoluciÃ³n Implementada

Eliminamos todas las variables que contienen informaciÃ³n directa sobre el balance:

```python
EXCLUDED = ['avg_balance', 'min_balance', 'max_balance', 
            'last_balance', 'spend_to_balance_ratio']
```

Esto fuerza al modelo a encontrar patrones en el **comportamiento** que correlacionen con el riesgo, sin tener acceso a la "respuesta" implÃ­cita.

---

## 4. Modelado

### 4.1 Algoritmos Evaluados

Se entrenaron tres modelos con las mismas 14 features conductuales:

1. **Logistic Regression**: Baseline interpretable, Ãºtil para inferencia causal
2. **Random Forest**: Ensemble de Ã¡rboles, captura no-linealidades
3. **XGBoost**: Gradient boosting, estado del arte en competencias de ML

### 4.2 ConfiguraciÃ³n

- **DivisiÃ³n de datos**: 80% train, 20% test (estratificado)
- **Manejo de desbalanceo**: `class_weight='balanced'` / `scale_pos_weight`
- **ValidaciÃ³n**: MÃ©tricas en conjunto de test no visto durante entrenamiento

---

## 5. Resultados

### 5.1 MÃ©tricas de EvaluaciÃ³n

| Modelo | ROC-AUC | Gini | KS |
|--------|---------|------|-----|
| Logistic Regression | 0.6520 | 0.3039 | 0.2006 |
| Random Forest | 0.6613 | 0.3227 | 0.2154 |
| **XGBoost** | **0.6640** | **0.3280** | **0.2206** |

### 5.2 ComparaciÃ³n Visual de MÃ©tricas

![ComparaciÃ³n de MÃ©tricas](metricas_comparacion.png)

*Figura 1: ComparaciÃ³n de ROC-AUC, Gini y KS entre los tres modelos. XGBoost obtiene el mejor desempeÃ±o.*

### 5.3 Curvas ROC

![Curvas ROC](curvas_roc.png)

*Figura 2: Curvas ROC de los tres modelos. Todas superan la lÃ­nea diagonal (clasificador aleatorio).*

### 5.4 InterpretaciÃ³n de MÃ©tricas

| MÃ©trica | Valor Obtenido | InterpretaciÃ³n |
|---------|----------------|----------------|
| AUC = 0.664 | 16% mejor que azar | Capacidad predictiva moderada |
| Gini = 0.328 | > 0.30 es aceptable | DiscriminaciÃ³n razonable |
| KS = 0.221 | > 0.20 es Ãºtil | SeparaciÃ³n de distribuciones |

### 5.5 Variables MÃ¡s Importantes

![Feature Importance](feature_importance.png)

*Figura 3: Importancia de variables en el modelo XGBoost. Las variables de comportamiento de gasto dominan.*

El modelo XGBoost identificÃ³ las siguientes features como mÃ¡s predictivas:

| Ranking | Variable | Importancia | InterpretaciÃ³n |
|---------|----------|-------------|----------------|
| 1 | `avg_spend` | 0.18 | Nivel de gasto promedio |
| 2 | `spending_volatility` | 0.15 | Estabilidad del consumo |
| 3 | `total_transactions` | 0.12 | Volumen de actividad |
| 4 | `transaction_density` | 0.11 | Frecuencia de uso |
| 5 | `age` | 0.10 | Factor demogrÃ¡fico |

### 5.6 Hallazgo EconÃ³mico

Los clientes de **alto riesgo** tienden a mostrar:
- Mayor **volatilidad** en sus gastos (comportamiento errÃ¡tico)
- Menor **consistencia** (actividad esporÃ¡dica)
- Menor **densidad transaccional** (usan poco la cuenta)

Esto es consistente con la teorÃ­a de consumo: agentes con restricciones de liquidez y/o shocks de ingreso muestran patrones de gasto mÃ¡s errÃ¡ticos.

---

## 6. DistribuciÃ³n del Riesgo en la Muestra

![DistribuciÃ³n de Riesgo](distribucion_riesgo.png)

*Figura 4: ProporciÃ³n de clientes de alto y bajo riesgo en el dataset.*

---

## 7. Ejemplo de AplicaciÃ³n

### Cliente: Juan (Bajo Riesgo)

| Variable | Valor | InterpretaciÃ³n |
|----------|-------|----------------|
| `spending_volatility` | 0.40 | Gastos estables |
| `transaction_density` | 1.5 | Actividad frecuente |
| `spending_consistency` | 0.80 | Comportamiento regular |

**Resultado:** Probabilidad de riesgo = 23% â†’ **BAJO RIESGO âœ…**

### Cliente: MarÃ­a (Alto Riesgo)

| Variable | Valor | InterpretaciÃ³n |
|----------|-------|----------------|
| `spending_volatility` | 2.5 | Gastos errÃ¡ticos |
| `transaction_density` | 0.3 | Actividad esporÃ¡dica |
| `spending_consistency` | 0.30 | Comportamiento irregular |

**Resultado:** Probabilidad de riesgo = 78% â†’ **ALTO RIESGO âŒ**

---

## 8. Limitaciones y Trabajo Futuro

### 8.1 Limitaciones

1. **DefiniciÃ³n de riesgo**: El target (`high_risk_flag`) es una proxy basada en balance vs. gasto, no en defaults reales
2. **Muestra**: Dataset de un solo paÃ­s y perÃ­odo temporal
3. **Variables omitidas**: No se incluyen variables macroeconÃ³micas ni de ingreso

### 8.2 Extensiones Posibles

1. **Incorporar datos de default real**: Usar informaciÃ³n de prÃ©stamos impagos como target
2. **AnÃ¡lisis temporal**: Evaluar estabilidad del modelo en diferentes perÃ­odos econÃ³micos
3. **SegmentaciÃ³n**: Entrenar modelos especÃ­ficos por segmento demogrÃ¡fico
4. **Deployment**: Crear API para scoring en tiempo real

---

## 9. Conclusiones

Este proyecto demuestra que:

1. **El comportamiento transaccional contiene informaciÃ³n predictiva** sobre el riesgo crediticio, independientemente del nivel de activos
2. **La identificaciÃ³n de data leakage es crÃ­tica** para producir modelos honestos y aplicables en producciÃ³n
3. **Un AUC de 0.66 es realista** para un modelo sin acceso a informaciÃ³n privilegiada sobre el balance

El enfoque behavioral puede complementar los mÃ©todos tradicionales de credit scoring, especialmente para segmentos de la poblaciÃ³n sin historial crediticio establecido.

---

## Referencias

- Samuelson, P.A. (1938). "A Note on the Pure Theory of Consumer's Behaviour". Economica.
- Hastie, T., Tibshirani, R., & Friedman, J. (2009). *The Elements of Statistical Learning*. Springer.
- Chen, T., & Guestrin, C. (2016). "XGBoost: A Scalable Tree Boosting System". KDD.

---

## Anexo: CÃ³digo y Recursos

**Repositorio GitHub:** [github.com/lucacamus13/Scoring-bancario](https://github.com/lucacamus13/Scoring-bancario)

| Archivo | DescripciÃ³n |
|---------|-------------|
| `notebooks/limpieza-y-carga-a-query.ipynb` | ETL y carga a BigQuery |
| `notebooks/03_eda.ipynb` | AnÃ¡lisis Exploratorio |
| `notebooks/05_behavioral_scoring.ipynb` | Modelo final |
| `sql/02_customer_features.sql` | Feature Engineering |

---

*Documento generado como parte del proyecto NeoScore - Alternative Credit Scoring*
