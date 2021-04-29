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
	data=ehact_2014_raw(drop=tucaseid)
	maxdec=1
	missing
	n /* number of observations */
	nmiss /* number of missing values */
	min q1 median q3 max  /* five-number summary */
	mean std /* two-number summary */
		; 
	var
		EUEDUR24
	; 
	label
		EUEDUR24="Second Eating Duration given activity"
	;
run;
title;

*Creating common format for values in 3 data sets;
proc format; 
	value miss 
		-1,-2,-3= "invalid"
		;
run;

title "Frequency Table of Secondary Eating";
proc freq
        data=ehact_2014_raw
        noprint
    ;
    table
        EUEDUR24
        /out= secondary_eating_table
    ;
run;
title;

title "Inspect EUEDUR4 from ehresp_2014_raw";

proc print data=primary_eating_table;
	format
		euedur24 miss.;
	label 
		EUEDUR24="Second Eating Duration given activity";
run;

*Sort the data by Patient ID and second eating activities;
proc sort data=resp_actvity_2014_file_v1;
	by
		tucaseid
		tuactivity_n 
	;
run;
 
*Test for normality;
proc univariate data=resp_actvity_2014_file_v1 normal;
	by 
		tuactivity_n
	;
	var 
		euedur24
	;
	qqplot /normal (mu=est sigma=est);
run;
 
*Test for equality of variances and perform anova;
proc glm data=resp_actvity_2014_file_v1;
	class 
		tuactivity_n
	;
	model 
		euedur24= tuactivity_n;
	means treatment 
	/ hovtest=levene(type=abs) welch;
	lsmeans treatment 
	/pdiff adjust=tukey plot=meanplot(connect cl) lines;
run;
quit;

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

Limitations: Several entries in ERTPREAT and ERTSEAT are coded as negative values
which seems to be illogical. However, those entries indicate "unanswered" or 
blank values, which can be removed prior to analyzing data.
*/ 

proc freq data=resp_actvity_2014_file_v1 nlevels;
	table 
		ERTPREAT ERTSEAT;
	format 
		ERTSEAT miss.;
run;

proc corr data=resp_actvity_2014_file_v1; 
	var 
		ertpreat; 
	with 
		ertseat; 
run; 

title "Scatterplot of Primary vs Secondary Eating";
proc gplot data=resp_actvity_2014_file_v1; 
	plot 
		ertpreat*ertseat; 
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
		   
Note: Perform two-sample t-test(duration) on the columns EUEXERCISE and 
ERTSEAT of ehresp_2014_raw. 

Limitations: Several entries in ERTSEAT are coded as negative values
which seems to be illogical. However, those entries indicate "unanswered" or 
blank values, which can be removed prior to analyzing data.

*/ 
proc means data=resp_actvity_2014_file_v1
	maxdec=1
	missing
	n /* number of observations */
	nmiss /* number of missing values */
	min q1 median q3 max  /* five-number summary */
	mean std /* two-number summary */
run;
title;

proc sgplot data=resp_actvity_2014_file_v1; 
	format 
		euexercise miss.;
	vbox 
		ertseat/ category=euexercise; 
run;

