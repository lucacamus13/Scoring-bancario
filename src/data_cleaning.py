"""
NeoScore - Funciones de limpieza de datos
"""

import re
import pandas as pd
import numpy as np


def sanitize_column_names(df: pd.DataFrame) -> pd.DataFrame:
    """
    Convierte nombres de columnas a snake_case compatible con BigQuery.
    
    Args:
        df: DataFrame con columnas a sanitizar
        
    Returns:
        DataFrame con columnas renombradas
    """
    new_columns = {}
    for col in df.columns:
        new_name = re.sub(r'\s*\([^)]*\)', '', col)
        new_name = new_name.replace(' ', '_')
        new_name = new_name.lower()
        new_name = re.sub(r'[^a-z0-9_]', '', new_name)
        new_name = re.sub(r'_+', '_', new_name)
        new_name = new_name.strip('_')
        new_columns[col] = new_name
    
    return df.rename(columns=new_columns)


def clean_dates(df: pd.DataFrame, date_col: str, zombie_dates: list = None) -> pd.DataFrame:
    """
    Limpia columnas de fecha, reemplazando fechas zombi por None.
    
    Args:
        df: DataFrame
        date_col: Nombre de la columna de fecha
        zombie_dates: Lista de valores a considerar como zombi
        
    Returns:
        DataFrame con fechas limpias
    """
    if zombie_dates is None:
        zombie_dates = ['1/1/1800', '01/01/1800', 'nan', 'NaN', 'NaT', '']
    
    df = df.copy()
    df[date_col] = df[date_col].replace(zombie_dates, None)
    df[date_col] = pd.to_datetime(df[date_col], format='%d/%m/%y', errors='coerce')
    
    # Corregir años futuros
    mask_future = df[date_col] > pd.Timestamp.now()
    df.loc[mask_future, date_col] = df.loc[mask_future, date_col] - pd.DateOffset(years=100)
    
    return df


def calculate_age(dob_series: pd.Series) -> pd.Series:
    """
    Calcula la edad a partir de fecha de nacimiento.
    
    Args:
        dob_series: Serie con fechas de nacimiento
        
    Returns:
        Serie con edades calculadas
    """
    today = pd.Timestamp.now()
    age = (today - dob_series).dt.days // 365
    return age.where(dob_series.notna(), None)
