NFL Home Game Attendance: A Multi-Language Regression Analysis
Description
This project investigates the significant predictors of NFL home game attendance using a multi-language analytical pipeline spanning SQL, Python, and R. Adapted from a Business Analytics course (ST541, Fall 2025), the project demonstrates competency across all three languages by assigning each a distinct role in the analysis workflow.
The dataset covers NFL seasons from 2000 onward and includes game-level results, team standings, and weekly attendance figures.
Workflow

SQL (via Marimo) — Initial dataframe joins across the three source datasets using chained CTEs, leveraging Marimo's native SQL support.
Python (Polars) — Data cleaning, feature engineering, and variable generation (e.g., win/loss streaks calculated across both home and away games).
R (lme4 / lmerTest) — Mixed-effects regression modeling, model comparison, multicollinearity diagnostics, and backwards elimination to identify the best-fitting model.

Key Analytical Steps

Control for team fixed effects across all models
Compare models with year fixed effects vs. year random effects and week fixed effects vs. week random effects
Select the best model using AIC and BIC criteria
Remove variables with high multicollinearity (VIF)
Apply backwards elimination to arrive at a parsimonious final model

Project Structure
├── NFL_regression_practice.py   # Marimo notebook (SQL + Python pipeline)
├── attendance_regression_analysis.R  # R script for mixed-effects modeling
├── standings.csv                # Team season-level standings & ratings
├── Attendance.csv               # Weekly and yearly attendance figures
├── games.csv                    # Game-level results and box scores
├── pixi.toml                    # Pixi environment configuration
└── pixi.lock                    # Pixi lockfile
Environment Setup
This project uses Pixi for environment management. To get started:
bashpixi install
Key Dependencies

Python 3.13 — Marimo, Polars, PyArrow, DuckDB, NumPy
R — lme4, lmerTest, car, ggplot2, dplyr, broom.mixed

Usage

Run the Marimo notebook to perform data joins, cleaning, and export the final dataframe:

bash   pixi run marimo edit NFL_regression_practice.py

Run the R script to perform model comparisons and regression analysis:

bash   Rscript attendance_regression_analysis.R
