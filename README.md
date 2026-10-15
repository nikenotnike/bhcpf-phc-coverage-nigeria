[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23404919.svg)](https://doi.org/10.5281/zenodo.23404919)

# BHCPF Disbursement and PHC Doctor Coverage in Nigeria

An analysis of whether federal health financing (BHCPF) predicts
primary healthcare doctor coverage across Nigerian states, controlling
for state fiscal capacity (IGR per capita).

## Research Question

Does BHCPF disbursement per capita predict the percentage of primary
healthcare facilities with a doctor present across Nigerian states?

## Data

- `data/analysis_combined_clean.rds` — cleaned state-level dataset (n = 27)
- `data/` — raw source files

##  Sources

- **BHCPF disbursement**: Federal Ministry of Health (2024). *The State of Health of the Nation Report 2024*. [Link](https://fmohconnect.gov.ng/wp-content/uploads/2025/05/The-State-of-Health-of-the-Nation-Report-2024.pdf)
- **IGR per capita**: National Bureau of Statistics (2024). *Internally Generated Revenue at State Level*. [Link](https://microdata.nigerianstat.gov.ng/index.php/catalog/170/related-materials)
- **PHC doctor coverage**: BudgIT (2026). *PHC Accountability Report*. [Link](https://budgit.org/wp-content/uploads/2026/06/PHC-Accountability-Report.Finalll.pdf)
- **Doctor distribution**: Federal Ministry of Health (2024). *The State of Health of the Nation Report 2024*. [Link](https://fmohconnect.gov.ng/wp-content/uploads/2025/05/The-State-of-Health-of-the-Nation-Report-2024.pdf)
- **Population**: Federal Ministry of Health (2024). *The State of Health of the Nation Report 2024*. [Link](https://fmohconnect.gov.ng/wp-content/uploads/2025/05/The-State-of-Health-of-the-Nation-Report-2024.pdf)

## Pipeline

- `01_analysis_first_draft.R` — imports raw data, cleans and merges, saves cleaned dataset
- `02_analysis_final.R` — loads cleaned data, runs regressions, generates figures

Run the scripts in order to reproduce the full analysis.

## Outputs

- `figures/figure1_phc_coverage.png` — main figure
- `outputs/descriptive_table.csv` — descriptive statistics
- `outputs/model_results.txt` — regression summaries

## Key Findings

- BHCPF per capita was not significantly associated with PHC doctor coverage
- IGR per capita was a significant positive predictor (p = 0.032)
- See `outputs/model_results.txt` for full results

## How to Reproduce

1. Clone the repository
2. Open R or RStudio
3. Set the working directory to the repository root
4. Run `01_data_preparation.R`
5. Run `02_analysis.R`

## Software

R version: [paste from `outputs/session_info.txt`]
Key packages: dplyr, ggplot2, patchwork, tidyr, tidyverse

## Contact

Shekinah Nikè Adaramola
shekinahadaramola@gmail.com