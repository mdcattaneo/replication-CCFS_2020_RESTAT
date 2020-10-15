// Clean CRSP data

* Initialize
clear
capture log close
set more off
* Make sure all appropriate variables are doubles rather than floats
set type double, permanently

* Change directory
cd "###"

* Make new CSV file?
local MakeCSV "Yes"

* Import monthly CRSP data
use 0044d89790c8e71b_20160511, clear

* Make date variable
gen datey = year(date)
gen datem = month(date)
gen dateym = ym(datey,datem)
format dateym %tm

* Restrict data to specific exchanges  [exchcd = 1 (NYSE), 2 (NJSEY MKT), 3 (NASDAQ)]
keep if exchcd == 1 | exchcd == 2 | exchcd == 3
keep if shrcd == 10 | shrcd == 11

* Drop "Funds, Trusts, and Other Financial Vehicles" (NAICS code beginning in 525)
*gen naicsTrunc = substr(naics,1,3)
*keep if naicsTrunc ~= "525"

* Drop duplicates which seem to have to do with dividend payment timing etc.
duplicates drop permco permno dateym ret cusip ncusip prc shrout shrcls, force

* Change shrout=0 to missing (see p. 147 in Bali, Engle and Murray (2016))
replace shrout = . if shrout == 0

* Deal with delisting returns (follow pp. 111-13 in Bali, Engle and Murray (2016))
gen dlstcdIND = 0 if ~missing(dlstcd) & dlstcd >= 200
replace dlstcdIND = 1 if (dlstcd >= 551 & dlstcd <= 573) | dlstcd == 500 | dlstcd == 520 | dlstcd == 574 | dlstcd == 580 | dlstcd == 584 

replace ret = dlret if ~missing(dlret) & ~missing(dlstcdIND)

replace ret = -0.3 if missing(dlret) & dlstcdIND == 1
replace ret = -1.0 if missing(dlret) & dlstcdIND == 0

* Generate market equity
gen mkt_eqtyTEMP   = abs(prc*shrout)
* Aggregate duplicate permno for each permco
egen mktEqty = total(mkt_eqty), by(permco dateym) missing

xtset permno dateym
gen mktEqtyLag = l.mktEqty

* Generate momentum anomalie variables
gen momentum7_2 = (1+l2.ret)*(1+l3.ret)*(1+l4.ret)*(1+l5.ret)*(1+l6.ret)*(1+l7.ret)-1
gen momentum12_2 = (1+l2.ret)*(1+l3.ret)*(1+l4.ret)*(1+l5.ret)*(1+l6.ret)*(1+l7.ret)*(1+l8.ret)*(1+l9.ret)*(1+l10.ret)*(1+l11.ret)*(1+l12.ret)-1

gen momentum12_2_SQ = momentum12_2^2
gen momentum12_2_CU = momentum12_2^3
gen momentum12_2_FO = momentum12_2^4

* Generate long-term reversal
gen reversal60_13 = 1
forvalue j = 13/60 {
replace reversal60_13 = reversal60_13*(1+l`j'.ret)
}
replace reversal60_13 = reversal60_13-1
replace reversal60_13 = . if missing(l61.prc)

* Generate short-term reversal
gen reversal1 = l.ret if ~missing(l2.prc)

*gen newsic = floor(siccd/100) if !missing(siccd)

* Generate industry dummies
* missing SIC codes are set to zero?
gen ind1 = siccd > 0 & siccd < 1000 if siccd ~= 0 & ~missing(siccd)
gen ind2 = siccd >= 1000 & siccd < 1300 if siccd ~= 0 & ~missing(siccd)
gen ind3 = siccd >= 1300 & siccd < 1400 if siccd ~= 0 & ~missing(siccd)
gen ind4 = siccd >= 1400 & siccd < 1500 if siccd ~= 0 & ~missing(siccd)
gen ind5 = siccd >= 1500 & siccd < 1800 if siccd ~= 0 & ~missing(siccd)
gen ind6 = siccd >= 2000 & siccd < 2100 if siccd ~= 0 & ~missing(siccd)
gen ind7 = siccd >= 2100 & siccd < 2200 if siccd ~= 0 & ~missing(siccd)
gen ind8 = siccd >= 2200 & siccd < 2300 if siccd ~= 0 & ~missing(siccd)
gen ind9 = siccd >= 2300 & siccd < 2400 if siccd ~= 0 & ~missing(siccd)
gen ind10 = siccd >= 2400 & siccd < 2500 if siccd ~= 0 & ~missing(siccd)
gen ind11 = siccd >= 2500 & siccd < 2600 if siccd ~= 0 & ~missing(siccd)
gen ind12 = siccd >= 2600 & siccd <= 2661 if siccd ~= 0 & ~missing(siccd)
gen ind13 = siccd >= 2700 & siccd < 2800 if siccd ~= 0 & ~missing(siccd)
gen ind14 = siccd >= 2800 & siccd < 2900 if siccd ~= 0 & ~missing(siccd)
gen ind15 = siccd >= 2900 & siccd < 3000 if siccd ~= 0 & ~missing(siccd)
gen ind16 = siccd >= 3000 & siccd < 3100 if siccd ~= 0 & ~missing(siccd)
gen ind17 = siccd >= 3100 & siccd < 3200 if siccd ~= 0 & ~missing(siccd)
gen ind18 = siccd >= 3200 & siccd < 3300 if siccd ~= 0 & ~missing(siccd)
gen ind19 = siccd >= 3300 & siccd < 3400 if siccd ~= 0 & ~missing(siccd)
gen ind20 = siccd >= 3400 & siccd < 3500 if siccd ~= 0 & ~missing(siccd)
gen ind21 = siccd >= 3500 & siccd < 3600 if siccd ~= 0 & ~missing(siccd)
gen ind22 = siccd >= 3600 & siccd < 3700 if siccd ~= 0 & ~missing(siccd)
gen ind23 = siccd >= 3700 & siccd < 3800 if siccd ~= 0 & ~missing(siccd)
gen ind24 = siccd >= 3800 & siccd <= 3879 if siccd ~= 0 & ~missing(siccd)
gen ind25 = siccd >= 3900 & siccd < 4000 if siccd ~= 0 & ~missing(siccd)
gen ind26 = siccd >= 4000 & siccd < 4800 if siccd ~= 0 & ~missing(siccd)
gen ind27 = siccd >= 4800 & siccd <= 4829 if siccd ~= 0 & ~missing(siccd)
gen ind28 = siccd >= 4830 & siccd < 4900 if siccd ~= 0 & ~missing(siccd)
gen ind29 = siccd >= 4900 & siccd <= 4949 if siccd ~= 0 & ~missing(siccd)
gen ind30 = siccd >= 4950 & siccd <= 4959 if siccd ~= 0 & ~missing(siccd)
gen ind31 = siccd >= 4960 & siccd <= 4969 if siccd ~= 0 & ~missing(siccd)
gen ind32 = siccd >= 4970 & siccd <= 4979 if siccd ~= 0 & ~missing(siccd)
gen ind33 = siccd >= 5000 & siccd < 5200 if siccd ~= 0 & ~missing(siccd)
gen ind34 = siccd >= 5200 & siccd < 6000 if siccd ~= 0 & ~missing(siccd)
gen ind35 = siccd >= 6000 & siccd < 7000 if siccd ~= 0 & ~missing(siccd)
gen ind36 = siccd >= 7000 & siccd < 9000 if siccd ~= 0 & ~missing(siccd)
gen ind37 = siccd >= 9000 & siccd <= 9999 if siccd ~= 0 & ~missing(siccd)

* Generate 12 industry dummies
gen ind12_1 = (siccd >= 100 & siccd < 1000) | (siccd >= 2000 & siccd < 2400) | ///
	(siccd >= 2700 & siccd < 2750) | (siccd >= 2770 & siccd < 2800) | ///
	(siccd >= 3100 & siccd < 3200) | (siccd >= 3940 & siccd < 3990) ///
	if siccd ~= 0 & ~missing(siccd)	
	
gen ind12_2 = (siccd >= 2500 & siccd < 2520) | (siccd >= 2590 & siccd < 2600) | ///	
	(siccd >= 3630 & siccd < 3660) | (siccd >= 3710 & siccd < 3712) | ///	
	(siccd >= 3714 & siccd < 3715) | (siccd >= 3716 & siccd < 3717) | ///	
	(siccd >= 3750 & siccd < 3752) | (siccd >= 3792 & siccd < 3793) | ///	
	(siccd >= 3900 & siccd < 3940) | (siccd >= 3990 & siccd < 4000) ///
	if siccd ~= 0 & ~missing(siccd)

gen ind12_3 = (siccd >= 2520 & siccd < 2590) | (siccd >= 2600 & siccd < 2700) | ///		
	(siccd >= 2750 & siccd < 2770) | (siccd >= 3000 & siccd < 3100) | ///		
	(siccd >= 3200 & siccd < 3570) | (siccd >= 3580 & siccd < 3630) | ///		
	(siccd >= 3700 & siccd < 3710) | (siccd >= 3712 & siccd < 3714) | ///		
	(siccd >= 3715 & siccd < 3716) | (siccd >= 3717 & siccd < 3750) | ///		
	(siccd >= 3752 & siccd < 3792) | (siccd >= 3793 & siccd < 3800) | ///		
	(siccd >= 3830 & siccd < 3840) | (siccd >= 3860 & siccd < 3900) ///
	if siccd ~= 0 & ~missing(siccd)

gen ind12_4 = (siccd >= 1200 & siccd < 1400) | (siccd >= 2900 & siccd < 3000) ///
	if siccd ~= 0 & ~missing(siccd)
	
gen ind12_5 = (siccd >= 2800 & siccd < 2830) | (siccd >= 2840 & siccd < 2900) ///
	if siccd ~= 0 & ~missing(siccd)
	
gen ind12_6 = (siccd >= 3570 & siccd < 3580) | (siccd >= 3660 & siccd < 3693) | ///
	(siccd >= 3694 & siccd < 3700) | (siccd >= 3810 & siccd < 3830) | ///
	(siccd >= 7370 & siccd < 7380) if siccd ~= 0 & ~missing(siccd)
	
gen ind12_7 = (siccd >= 4800 & siccd < 4900) if siccd ~= 0 & ~missing(siccd)

gen ind12_8 = (siccd >= 4900 & siccd < 4950) if siccd ~= 0 & ~missing(siccd)

gen ind12_9 = (siccd >= 5000 & siccd < 6000) | (siccd >= 7200 & siccd < 7300) | ///
	(siccd >= 7600 & siccd < 7700) if siccd ~= 0 & ~missing(siccd)
	
gen ind12_10 = (siccd >= 2830 & siccd < 2840) | (siccd >= 3693 & siccd < 3694) | ///
	(siccd >= 3840 & siccd < 3860) | (siccd >= 8000 & siccd < 8100) if siccd ~= 0 & ~missing(siccd)	
	
gen ind12_11 = (siccd >= 6000 & siccd < 7000) if siccd ~= 0 & ~missing(siccd)
	
* Need to define "other" category for 12 industries
gen tempind11 = ind12_1
forvalue j = 2/11 {
	replace tempind11 = tempind11 + ind12_`j'
}
gen ind12_12 = 0 if tempind11 == 1
replace ind12_12 = 1 if tempind11 == 0

* Generate industry momentum variables
gen mktEqtyLag13 = l13.mktEqty

gen ind12momentum12_2 = .
forvalues i = 1/12 {
	bysort dateym: egen tempMktEqtyLag = total(mktEqtyLag13) if ind12_`i' == 1
	bysort dateym: egen tempMomentumVW = total(mktEqtyLag13*momentum12_2/tempMktEqtyLag) if ind12_`i' == 1	
	replace ind12momentum12_2 = tempMomentumVW if ind12_`i' == 1	
	drop temp*
}

gen ind12momentum12_2_SQ = ind12momentum12_2^2
gen ind12momentum12_2_CU = ind12momentum12_2^3
gen ind12momentum12_2_FO = ind12momentum12_2^4


gen ind37momentum12_2 = .
forvalues i = 1/37 {
	bysort dateym: egen tempMktEqtyLag = total(mktEqtyLag13) if ind`i' == 1
	bysort dateym: egen tempMomentumVW = total(mktEqtyLag13*momentum12_2/tempMktEqtyLag) if ind`i' == 1	
	replace ind37momentum12_2 = tempMomentumVW if ind`i' == 1	
	drop temp*
}

gen ind37momentum12_2_SQ = ind37momentum12_2^2
gen ind37momentum12_2_CU = ind37momentum12_2^3
gen ind37momentum12_2_FO = ind37momentum12_2^4

* Make csv file for Matlab
if "`MakeCSV'" == "Yes" {
	preserve
	*gen year = year(dofm(dateym))
	*gen month = month(dofm(dateym))
	drop dateym
	order permno datey datem ret, first
	keep permno datey datem ret mktEqty mktEqtyLag momentum12_2* ind* 
	ds permno datey datem, not
	foreach x of varlist `r(varlist)'{
		replace `x' = -999 if `x' == .
	}
	export delimited using "CRSPonly.csv", delimiter(",") novarnames replace
	local n = _N
	drop in 1/`n'
	export delimited using "CRSPonlyLabels.csv", delimiter(",") replace
	restore
	
	preserve
	keep if exchcd == 1
	drop dateym
	order permno datey datem ret, first
	keep permno datey datem ret mktEqty mktEqtyLag momentum12_2* ind* 
	ds permno datey datem, not
	foreach x of varlist `r(varlist)'{
		replace `x' = -999 if `x' == .
	}
	export delimited using "NYSEonly.csv", delimiter(",") novarnames replace
	local n = _N
	drop in 1/`n'
	export delimited using "NYSEonlyLabels.csv", delimiter(",") replace
	restore		
}

save CRSPonly, replace
