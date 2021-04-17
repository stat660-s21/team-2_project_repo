

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
Question 1 of 3: What type(s) of activities are more likely to be associated 
with secondary eating?

Rationale: Knowing which type(s) of activities increase(s) the likelihood of 
secondary eating could help devise preventive strategies.
		   
Note: Perform onw-way ANOVA with EUEDUR24 as the response variable and 
TUACTIVITU_N as factors.

Limitations: Many entries in EUEDUR24 are coded -1 which seems to be illogical. 
However, those entries indicate "unanswered" or missing values, which can be 
removed prior to analyzing data. 
*/

title "Descriptive Statistics for ehact_2014";
proc means
        data=ehact_2014
        maxdec=1
        missing
        n /* number of observations */
        nmiss /* number of missing values */
        min q1 median q3 max  /* five-number summary */
        mean std /* two-number summary */
run;
title;

proc freq
        data=ehact_2014
        noprint
    ;
    table
        ERTSEAT
        / out= primary_eating_table
    ;
run;

*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 3: Is there a relationship between primary and seconday eating 
among households?
				 
Rationale: By answering this question helps generalize common eating habits 
of people.

Note: Find the correlation between the columns ERTPREAT and ERTSEAT of 
ehresp_2014_raw. 

Limitations: Several entries in ERTPEAT and ERTSEAT are coded as negative values
which seems to be illogical. However, those entries indicate "unanswered" or 
blank values, which can be removed prior to analyzing data.
*/ 

proc freq
        data=ehresp_2014
        noprint
    ;
    table
        PCTGE1500
        / out=sat15_PCTGE1500_frequencies
    ;
run;


*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: Is there a significant difference in secondary eating
among people who exercise and who do not?
				 
Rationale: By statistically prove that exercise can positivel affect the habit 
of secondary eating, we can promote the idea and encourage people to do more
physical activities. 
		   
Note: Perform two-sample t-test(duration) on the columns ERTPREAT and 
ERTSEAT of ehresp_2014_raw. 

Limitations: Several entries in ERTSEAT are coded as negative values
which seems to be illogical. However, those entries indicate "unanswered" or 
blank values, which can be removed prior to analyzing data.

*/ 

proc means
        data=ehwgts_2014
        maxdec=1
        missing
        n /* number of observations */
        nmiss /* number of missing values */
        min q1 median q3 max  /* five-number summary */
        mean std /* two-number summary */
run;
title;



