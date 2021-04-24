*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/*
create macro variable with path to directory where this file is located,
enabling relative imports
*/
%let path=%sysfunc(tranwrd(%sysget(SAS_EXECFILEPATH),%sysget(SAS_EXECFILENAME),));

/*
execute data-prep file, which will generate final analytic dataset used to
answer the research questions below
*/
%include "&path.STAT660-01_s21-team-2_data_preparation.sas";


*******************************************************************************;
* Research Question 1 Analysis Starting Point;
*******************************************************************************;
/*
Question 1 of 3: Do income levels affect how many times a person eats per day? 

Rationale: Households with higher incomes may be able to afford gym memberships 
perhaps explaining lower body weights. I would like to explore whether or not 
higher incomes lead to more cases of eating. 

Note: This compares the column ERINCOME in ehresp_2014.csv with
the highest n of the same ID in ehact_2014.csv. ERIncome is a categorical
with 5 levels corresponding to how much a household is above the baseline level
for poverty in the United States so proc freq will be used often.

1 - Income > 185% of poverty threshold
2 - Income < = 185% of poverty threshold
3 - 130% of poverty threshold < Income < 185% of poverty threshold
4 - Income > 130% of poverty threshold
5 - Income <= 130% of poverty threshold

Limitations: Values in ERINCOME not integers (1,5) should be excluded since 
these contain non-valid data.
*/

/* Output frequencies of ERINCOME to a dataset for manual inspection */
proc freq
    data = ehresp_2014_households
	noprint
	;
	table
	    ERINCOME
		/ out = TUACTIVITY_frequencies
	;
run;

/* use manual inspection to create bins to study missing-value distribution */
proc format;
    value $ERINCOME_bins
	    "1", ="Income > 185% of poverty threshold"
		"2"="Income < = 185% of poverty threshold"
		"3"="130% of poverty threshold < Income < 185% of poverty threshold"
		"4"="Income > 130% of poverty threshold"
		"5"="Income <= 130% of poverty threshold"
		other="Invalid entry"
	;
run;

/* inspect study missing-value distribution */
title "Inspect ERINCOME from ehresp_2014";
proc freq
    table
	    ERINCOME
		/ nocum
	;
	format
	    ERINCOME $ERINCOME_bins.
	;
	label ERINCOME="Counts of Households INCOME Category"
	;
run;
title;

/* Output frequencies of TUACTIVITY to a dataset for manual inspection */
proc freq
    data = ehact_2014_raw
	noprint
	;
	table
	    TUACTIVITY
		/ out = TUACTIVITY_frequencies
	;
	label
	    
run;
/* use manual inspection to create bins to study missing-value distribution */
proc format;
    value $TUACTIVITY
	    "0"="Potentially Missing"
		other="Valid Numberical Value"
	;
run;

/* Inspect missing-value distirbution */
title "Inspect TUACTIVITY from ehact_2014";
proc freq
        data=ehact_2014_households
	;
	table
	    TUACTIVITY
		/ nocum
	;
	format
	    TUACTIVITY $TUACTIVITY_bins.
	;
	label
	    TUACTIVITY="Count of households with second eating counts"
	;
run;
title;

    
*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 3: Is there a relationship between BMI ERBMI column in 
ehresp_2014.csv (body mass index) relationship between primary and secondary 
eating ehact_2014.csv?

Rationale: I've heard of conflicting reports between eating smaller meals, 
one large meal, or even fasting leading to lower BMI. Is there an observable 
pattern or relationship?

Note: This compares the column BMI ERBMI of ehresp_2014 with the highest value 
of tuactivity_n for the same ID in ehact_2014.csv.

Limitations: Values of bmi are only properly defined if the individual has
valid entries for height and weight that is EUHGT > 0 and EUWGT > 0.
*/
title "Inspect ERBMI from ehresp_2014.csv";
proc means
    data=ehresp_2014_households
    maxdec=1
    missing
    n /* number of observations */
    nmiss /* number of missing values */
    min q1 median q3 max /* five-number summary */
    mean std /* two-number summary */
;
var
    erbmi
    ;
    label
    erbmi=" "
	;
run;
title;


*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: Do people who exercise at least once a week, column EUEXERCISE 
in enresp2014.csv, determine how often they eat, activity number of secondary 
eatings enhact_2014?

Rationale: Do people who exercise tend to engage in secondary eating? 
Once again I've heard conflicting accounts. Sometimes people who go to the gym 
claim they need to eat protein rich meal for muscle growth. And I heard 
nutritionists talk about calories in and calories out.

Note: This compares the column EUEXERCISE of enresp2014.csv with the highest 
value of tuactivity_n for the same ID in ehact_2014.csv. EUEXERCISE is a
categorical variable with entries 1 - Yes or 2 - No. So I will need to count
frequencies.

Limitations: Values of Exercise are limited to integer values 1 or 2. 1-
exercise besides work 2 - no exercise.
*/

/* Output frequencies of EUEXERCISE to a dataset for manual inspection */
proc freq
    data = ehresp_2014_households
	noprint
	;
	table
	    ERINCOME
		/ out = TUACTIVITY_frequencies
	;
run;

/* use manual inspection to create bins to study missing-value distribution */
proc format;
    value $EUEXERCISE_bins
	    "1", ="Exercise in the Last 7 Days Besides Work"
		"2"="No Exercise in the Last 7 Days Besides Work"
		other="Invalid Numerical Value"
	;
run;

/* inspect study missing-value distribution */
title "Inspect EUEXERCISE from ehresp_2014";
proc freq
    table
	    EUEXERCISE
		/ nocum
	;
	format
	    EUEXERCISE $EUEXERCISE_bins.
	;
	label EUEXERCISE="Counts of Households INCOME Category"
	;
run;
title;
