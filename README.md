# 🏦 NeoScore - Alternative Credit Scoring

Sistema de scoring crediticio alternativo basado en comportamiento transaccional bancario.

## 🎯 Objetivo

Evaluar el riesgo crediticio de usuarios utilizando exclusivamente su historial de transacciones bancarias, sin depender de burós de crédito tradicionales.

## 🛠️ Stack Tecnológico

| Componente | Tecnología |
|------------|------------|
| **Almacenamiento** | Google BigQuery |
| **Procesamiento** | Python (Google Colab) |
| **Machine Learning** | Scikit-learn, XGBoost |
| **Visualización** | Matplotlib, Seaborn |

## 📊 Dataset

- **~1 millón** de transacciones bancarias
- **9 variables**: ID cliente, fecha nacimiento, género, ubicación, balance, fecha/hora transacción, monto

## 📁 Estructura del Proyecto

```
├── notebooks/           # Jupyter notebooks (Colab)
│   ├── 01_data_cleaning.ipynb
│   ├── 02_eda.ipynb
│   ├── 03_feature_engineering.ipynb
│   ├── 04_modeling.ipynb
│   └── 05_evaluation.ipynb
├── sql/                 # Consultas BigQuery
├── src/                 # Código Python reutilizable
├── data/                # Diccionario de datos (datos no incluidos)
├── reports/             # Reportes y visualizaciones
└── docs/                # Documentación adicional
```

## 📈 Metodología

1. **Data Cleaning**: Sanitización de datos y carga a BigQuery
2. **EDA**: Análisis exploratorio de datos
3. **Feature Engineering**: Creación de características por cliente
4. **Modeling**: Entrenamiento de modelos de clasificación
5. **Evaluation**: Métricas específicas de scoring (ROC-AUC, Gini, KS)

## 🚀 Quick Start

1. Clonar el repositorio
2. Abrir notebooks en Google Colab
3. Configurar proyecto en BigQuery
4. Ejecutar notebooks en orden

## 👤 Autor

**Luca Camus** - Economista | Data Scientist en formación

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://linkedin.com/in/lucacamus)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black)](https://github.com/lucacamus13)

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE) para más detalles.
