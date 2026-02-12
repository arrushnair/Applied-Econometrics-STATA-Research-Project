# Panel Data Analysis – Stata Code

This repository contains **Stata code for panel data analysis**. Follow the steps below to correctly run the code and reproduce the results.

---

## Prerequisites

1. Ensure the dataset **PanelDataG03.xlsx** is present in your Stata working directory.
2. Install the required Stata packages:

```stata
ssc install xtcsd, replace
ssc install multipurt, replace
ssc install xtpedroni, replace
ssc install xtpmg, replace
net install st0373, from(http://www.stata-journal.com/software/sj15-1)
```

---

## Data Preparation

### 1. Load the dataset
- Import the Excel file `PanelDataG03.xlsx` (Sheet1)
- Rename variables for easier reference

### 2. Create numeric country identifiers
- Convert string country names into numeric IDs

### 3. Data cleaning & transformation
- Drop observations with missing `rgdppc` or `pop`
- Replace zero or negative values with 1
- Create log-transformed variables

### 4. Declare panel structure
- Set `country_id` and `Year` as panel variables

```stata
xtset country_id Year
```

---

## Analysis Workflow

### Multicollinearity
- Run Variance Inflation Factor (VIF) test *(Table 5)*

### Cross-sectional Dependence Tests *(Table 6)*
- Test each variable individually
- Generate residuals and apply **Pesaran CD test**

### Regression CD Tests *(Table 7)*
- Estimate Random Effects model
- Apply:
  - Pesaran CD test  
  - Frees test  
  - Friedman test  

### Slope Homogeneity *(Table 8)*
- Perform **Pesaran–Yamagata test** using `xtmg`

### Panel Unit Root Tests
- **Without trend** *(Table 9)*  
  - CIPS test with intercept only  
  - Test levels and first differences  

- **With trend** *(Table 10)*  
  - CIPS test with intercept and trend  
  - Test levels and first differences  

### Cointegration Tests
- Westerlund ECM panel cointegration test *(Table 11)*
- Kao cointegration test *(Table 12)*

### Dynamic Panel Estimation *(Table 13)*
- System GMM estimation
- Models with and without interaction terms

### Static Panel Estimation *(Table 14)*
- Driscoll–Kraay standard errors
- Models with and without interaction terms

### Panel Time-Series Estimators *(Table 15)*
- PMG Estimator  
- AMG Estimator  
- CCEMG Estimator  

### Threshold Regression *(Table 16)*
- Panel threshold regression to identify threshold values

---

## Notes
- Table numbers correspond to those in the associated research paper/report.
- Ensure all dependencies are installed before running estimations to avoid errors.

---

