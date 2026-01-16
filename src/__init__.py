"""
NeoScore - Módulo principal
"""

from .data_cleaning import sanitize_column_names, clean_dates, calculate_age

__version__ = "0.1.0"
__all__ = ["sanitize_column_names", "clean_dates", "calculate_age"]
