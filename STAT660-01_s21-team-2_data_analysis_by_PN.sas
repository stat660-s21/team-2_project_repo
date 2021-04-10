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

Note: This compares the column of tuactivty in ehact_2014.csv with the column 
ERINCOME ehresp_2014.
*/


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
*/


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
value of tuactivity_n for the same ID in ehact_2014.csv.
*/
