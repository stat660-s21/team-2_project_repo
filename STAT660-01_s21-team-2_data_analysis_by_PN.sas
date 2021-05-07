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

/* Creating a format for ERINCOME so we can tell how much over threshold
a person's income is. */

proc format;
    value erincome_fmt    
        1 = "185%"
        2 = "< = 185%"
	    3 = "130% < Income < 185%"
	    4 = "Income > 130%"
        5 = "Income <= 130%";
run;

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

/* Scatter plot showing groupings of tuactivity and income levels. */	
proc sgscatter data = income_lvl_freq_eating_v2;
	where ERINCOME IN(1 2 3 4 5);
	format erincome erincome_fmt.;
	PLOT TUACTIVITY_N*ERINCOME;
run;

/* clear titles/footnotes */
title;
footnote;


*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*

Note: This compares the column BMI ERBMI of ehresp_2014 with the highest value 
of tuactivity_n for the same ID in ehact_2014.csv.

Limitations: Values of bmi are only properly defined if they are > 0.

Methodology: Use proc sort to create a temporary dataset in descending
order and then subsetting that set to obtain the higest value of each unique
id group. Body Mass Index (BMI) is binned into 4 categroies. Then create a 
scatter plot to see any patterns in the 4 categorical groups.

Followup Steps: Visual inspection of a scatterplot of categorical groups is
not rigorous, even though it can be a helpful initial step. An ANOVA or
categorical data analysis may yield further insights.
*/

/* Creating a format to group BMI into groups
Underweight - < 18.5
Normal - 18.5<bmi<24.9
Overweight - 25<bmi<29.9
Obese - >30
*/

proc format;
    value erbmi_group 1 = "Underweight"
                      2 = "Normal"
				      3 = "Overweight"
				      4 = "Obese";
run;

/* Creating a data set omitting invalid bmi values and sorting in descending
order tuactivity_n and selecting only first row of each unique tucaseid to have
data set with greatest number of tuactivity (eating frequency) */

proc sort data= resp_activity_2014_file_v2
    out = bmi_freq_eating_v1;
	where tuactivity_n is not missing and erbmi > 0;
    by tucaseid descending tuactivity_n;
run;

/* Assigning categorical code 1-4 for use with previously declared format with
conditional statements based on erbmi ranges. */

data bmi_freq_eating_v2;
    set bmi_freq_eating_v1;
	if erbmi < 18.5 THEN erbmi = 1;
	if 18.5<=erbmi<24.9 THEN erbmi = 2;
	if 24.9<=erbmi<29.9 THEN erbmi = 3;
	if erbmi >= 29.9 THEN erbmi = 4;
    by tucaseid;
	if first.tucaseid then output;
run;

title1 justify=left
'Question 2 of 3: Is there a relationship between BMI ERBMI column in 
ehresp_2014.csv (body mass index) relationship between primary and secondary 
eating ehact_2014.csv?'
;

title2 justify=left
'Rationale: I have heard of conflicting reports between eating smaller meals, 
 one large meal, or even fasting leading to lower BMI. Is there an observable 
 pattern or relationship?'
;

footnote1 justify=left
"It looks like people with underweight BMI eat less often than those with higher BMI. There
 does not seem to be a big difference between the number of eating activities between those
 with normal, overweight, and obese BMI. Maybe exercise of lack of it is a bigger factor."
;

/*scatter plot with bmi formating*/
proc sgscatter data = bmi_freq_eating_v2;
    format erbmi erbmi_group.;
	PLOT TUACTIVITY_N*erbmi;
run;

/* clear titles/footnotes */
title;
footnote;


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

Methodology: Use proc sort to create a temporary dataset in descending
order and then subsetting that set to obtain the higest value of each unique
id group. EUEXERCISE is divided into two groups, those that exercise weeekly
and those that do not, with this in mind a scatter plot is made.

Followup Steps: Visual inspection of a scatterplot of categorical groups is
not rigorous, even though it can be a helpful initial step. An ANOVA or
categorical data analysis may yield further insights.
*/

/* Format of euexercise. */

proc format;
    value euexer_freq 1 = "Exercise During Week"
	                   2 = "No Exercise During Week";
run;

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
"It looks that a few individuals that do exercise do in fact eat more often. This is consistent with bodybuilders
 that advocate eating many small meals or after work outs to fuel building of muscle with protein rich food. "
;

/*scatter plot with euexercise formating*/
proc sgscatter data = exer_lvl_freq_eating_v2;
    format euexercise euexer_freq.;
	PLOT TUACTIVITY_N*EUEXERCISE;
run;
