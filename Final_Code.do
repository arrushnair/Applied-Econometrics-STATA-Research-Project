ssc install xtcsd, replace
ssc install multipurt, replace
ssc install xtpedroni, replace
ssc install xtpmg, replace
net install st0373, from(http://www.stata-journal.com/software/sj15-1)


* 1. Load data and rename variables
import excel "PanelDataG03.xlsx", sheet("Sheet1") firstrow clear
rename FD                fd
rename INST_QUALITY      inst
rename FDxINST_QUALITY   fd_inst
rename REN               renew
rename RGDPPC            rgdppc
rename POP               pop
rename FDI               fdi

* 2. Create numeric country identifier
encode Country, gen(country_id)

* 3. Handle missing/zero values and create logged variables
drop if missing(rgdppc, pop) 
replace rgdppc = 1 if rgdppc <= 0  
replace pop = 1 if pop <= 0
gen lrgdppc = log(rgdppc)
gen lpop = log(pop)
gen lren=log(renew)

* 4. Declare panel structure
xtset country_id Year

* Variance Inflation Factor (VIF) Test(Table 5)
regress ren fd inst fd_inst lrgdppc fdi lpop
vif

* 5. Cross-sectional dependence tests (Table 6)
local vars ren fd inst fd_inst lrgdppc fdi lpop
foreach var of local vars {
    di "====================================================="
    di "Cross-sectional Dependence Tests for `var'"
    
    * Step 1: Run fixed effects regression of variable on its lag
    xtreg `var' L.`var', fe
    
    * Step 2: Check if residual variable already exists, and drop if it does
    capture drop resid_`var'
    
    * Step 3: Predict residuals
    predict resid_`var', e
    
    * Step 4: Run cross-sectional dependence tests using Pesaran's CD test
    xtcd resid_`var'
}


* 6. Regression CD tests (Table 7)
xtreg renew fd inst fd_inst lrgdppc fdi lpop, re
xtcsd, pesaran
xtcsd, frees
xtcsd, friedman

* 7. Slope homogeneity Pesaran Yamagata test (Table 8)
xtmg ren fd inst fd_inst lrgdppc fdi lpop  

* Table 9: Panel unit root tests (intercept only)
* CIPS test - intercept only
foreach var in renew fd inst fd_inst lrgdppc fdi lpop {
    * Level
    pescadf `var', lags(1)
    
    * First difference
    gen d_`var' = `var' - L.`var'
    pescadf D.`var', lags(1)
}

* Table 10: Panel unit root tests (intercept and trend)
* CIPS test - intercept and trend
foreach var in renew fd inst fd_inst lrgdppc fdi lpop {
    * Level
    pescadf `var', lags(1) trend

    * First difference
    pescadf D.`var', lags(1) trend
}


* Westerlund ECM panel cointegration tests(Table 11)
xtwest lren fd inst fd_inst lrgdppc fdi lpop, constant trend lags(0)

* Kao cointegration test(Table 12)
xtcointtest kao lren fd inst fd_inst lrgdppc fdi lpop

* 1. System GMM(Table 13)
* Without interaction term
xtabond2 renew L.renew fd inst lrgdppc fdi lpop, gmm(L.renew, lag(1 2)) gmm(fd inst lrgdppc fdi lpop, lag(2 3)) iv(i.Year) twostep robust


* With interaction 
xtabond2 renew L.renew fd inst fd_inst lrgdppc fdi lpop, gmm(L.renew, lag(1 2)) gmm(fd inst fd_inst lrgdppc fdi lpop, lag(2 3)) iv(i.Year) twostep robust

* 2. Driscoll-Kraay estimator(Table 14)
* Without interaction term
xtscc ren fd inst lrgdppc fdi lpop, fe

* With interaction term
xtscc ren fd inst fd_inst lrgdppc fdi lpop, fe

* 1. PMG Estimator (Table 15)
xtpmg d.renew d.fd d.inst d.fd_inst d.lrgdppc d.fdi d.lpop, lr(l.renew fd inst fd_inst lrgdppc fdi lpop) ec(ec) replace

* 2. AMG Estimator 
xtmg renew fd inst fd_inst lrgdppc fdi lpop

* 3. CCEMG Estimator 
xtmg renew fd inst fd_inst lrgdppc fdi lpop, cce

*Threshold values(Table 16)
xthreg lren fd lrgdppc lpop fdi, rx(inst) qx(inst) thnum(1) grid(400) trim(0.01) bs(500)