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
these contain non-valid data. Some individuals did not disclose the frequency
of how many times they ate food in a day.

Methodology: Use proc sort to create a temporary dataset in descending
order and then subsetting that set to obtain the higest value of each unique
id group. Then create a scatter plot to see any patterns in the 5 categorical
groups.

Followup Steps: Visual inspection of a scatterplot of categorical groups is
not rigorous, even though it can be a helpful initial step. An ANOVA or
categorical data analysis may yield further insights.
*/

/* I will now sort my data set in descending order so I can get the largest
value for tuactivity_n and extract the first row per every unique tucaseid so
I have a new data set. */

proc sort data= resp_activity_2014_file_v2
    out = income_lvl_freq_eating_v1;
	where tuactivity_n is not missing and erincome in (1 2 3 4 5);
    by tucaseid descending tuactivity_n;
run;

data income_lvl_freq_eating_v2;
    set income_lvl_freq_eating_v1;
    by tucaseid;

	if first.tucaseid then output;
run;

title1 justify=left
'Question 1 of 3: Do income levels affect how many times a person eats per day?'
;

title2 justify=left
'Rationale: Households with higher incomes may be able to eat out more often or maybe lower incomes leads 
 to eating more often. Maybe government programs will be needed to increase availability of food.'
;

footnote1 justify=left
"Of the five income groups with 1 being the highest threshold and 5 being the lowest, there does
 not look to be a pattern in terms of eating habits when everyone has an income above the poverty level."
;
	
proc sgscatter data = income_lvl_freq_eating_v2;
	where ERINCOME IN(1 2 3 4 5);
	PLOT TUACTIVITY_N*ERINCOME;
run;


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

Note: This compares the column EUEXERCISE of enresp2014.csv with the highest 
value of tuactivity_n for the same ID in ehact_2014.csv. EUEXERCISE is a
categorical variable with entries 1 - Yes or 2 - No. So I will need to count
frequencies.

Limitations: Values of Exercise are limited to integer values 1 or 2. 1-
exercise besides work 2 - no exercise.
*/

/* Output frequencies of EUEXERCISE to a dataset for manual inspection */

/* I will now sort my data set in descending order so I can get the largest
value for tuactivity_n and extract the first row per every unique tucaseid so
I have a new data set. */

proc sort data= resp_activity_2014_file_v2
    out = exer_lvl_freq_eating_v1;
	where tuactivity_n is not missing and euexercise IN (1, 2);
    by tucaseid descending tuactivity_n;
run;

data exer_lvl_freq_eating_v2;
    set exer_lvl_freq_eating_v1;
    by tucaseid;

	if first.tucaseid then output;
run;

title1 justify=left
'Question 3 of 3: Do people who exercise at least once a week, column EUEXERCISE 
 in enresp2014.csv, determine how often they eat, activity number of secondary 
 eatings enhact_2014?'
;

title2 justify=left
'Rationale: Do people who exercise tend to engage in secondary eating? Sometimes people who go to the gym 
claim they need to eat protein rich meal for muscle growth and more often with smaller meals.'
;

footnote1 justify=left
"Placeholder"
;
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
