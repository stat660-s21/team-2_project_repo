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
Note: Perform one-way ANOVA with EUEDUR24 as the response variable and 
TUTIER1CODE as independent variable.

Limitations: Many entries in EUEDUR24 are coded -1 which seems to be illogical. 
However, those entries indicate "unanswered" or missing values, which can be 
removed prior to analyzing data.

Methodology: Use proc sort to create a temporary sorted table in asscending
order by TUTIER1CODE, then use PROC GLM to perform One-way ANOVA and 
PROC UNIVARIATE to check assumptions.

Followup Steps: Since normality assumption is violated, non-parametric test can
considered (i.e Kruskal-Wallis Test) using PROC NPAR1WAY
*/

/* Sort by TUTIER1CODE and filter out invalid value for euedur24 */
proc sort data=resp_activity_2014_file_v3 out=temp ;
	where
		euedur24>0
	;  
	by 
		TUTIER1CODE
	; 
run;

title1 justify=left
" Question 1 of 3: Is there a significant difference in secondary eating
duration among activities?";

title2 justify=left
"Rationale: Knowing which type(s) of activities increase(s) the likelihood of 
secondary eating could help devise preventive strategies.";
		   
footnote1 justify=left
"The Chi-square Test p-value is less than 0, indicating that there is a 
statistically significiant difference in secondary eating time among 
activities";

footnote2 justify=left
"Futher pairwise comparison suggests that the mean secondary eating time for 
";

proc univariate data=temp normal;
	title 
		"Test for normality";	
	by 
		TUTIER1CODE
	;
	var 
		euedur24
	;
	qqplot /normal (mu=est sigma=est);
run;

/*Perform the Kruskal-Wallis Test;
proc npar1way data=temp wilcoxon dscf;
class TUTIER1CODE;
var euedur24;
run;*/

/*One-way ANOVA*/
proc glm data=temp;
	title 
		"Test for equality of variances and perform anova"
	;	
	class 
		TUTIER1CODE
	;
	model 
		euedur24= TUTIER1CODE;
	random
		TUTIER1CODE
	;
	means 
		TUTIER1CODE 
	/ hovtest=
		levene(type=abs) welch
	;
	lsmeans 
		TUTIER1CODE 
	/pdiff=all adjust=tukey ;
run;
quit;

proc sgplot data=temp; 
	title
		"Boxplots of Secondary Eating Duration by TUTIER1CODE"
	;
	vbox 
		euedur24
	/ category=
		TUTIER1CODE
	;
run;
title;
footnote;

*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
Note: Rank the activites by secondary eating duration in descending order.

Limitations:  Many entries in EUEDUR24 are coded -1 which seems to be illogical. 
However, those entries indicate "unanswered" or missing values, which can be 
removed prior to analyzing data.

Methodology: Use proc sort to create a temporary sorted table in descending
order by frpm_rate_change_2014_to_2015, with ties broken by school name. Then
use proc print to print the first five rows of the sorted dataset.

Followup Steps: More carefully clean values in order to filter out any possible
illegal values, and better handle missing data, e.g., by using a previous year's
data or a rolling average of previous years' data as a proxy.
*/
title1
"Secondary eating occurs the longest during what type(s) of activity?";
				 
title2
"Rationale: By answering this question helps generalize common eating habits 
of people.";

footnote1" Find the correlation between the columns ERTPREAT and ERTSEAT of 
ehresp_2014_raw";

footnote2" Several entries in ERTPREAT and ERTSEAT are coded as negative values
which seems to be illogical. However, those entries indicate "unanswered" or 
blank values, which can be removed prior to analyzing data.";

title3 "Frequency tables of primary and secondary eating";
proc freq data=resp_activity_2014_file_v2 nlevels;
	table 
		ERTPREAT ERTSEAT;
	format 
		ERTSEAT miss.;
run;

proc corr data=resp_activity_2014_file_v2; 
	var 
		ertpreat; 
	with 
		ertseat; 
run; 

title "Scatterplot of Primary vs Secondary Eating";
proc gplot data=resp_actvity_2014_file_v3; 
	plot 
		ertpreat*ertseat; 
run;
proc format; 
	value activity
		2="Household Activities"
		3="Caring/Helping for Household Members"
		4="Caring/Helping for Non-HH Members"
		5="Work & Work-Related Activities"
		6="Education"
		7="Consumer Purchases"
		8="Professional/Personal Care Services"
		9="Household Services"
		10="Goverment Services"
		11="Eating & Drinking"
		12="Socializing, Relaxing and Leisure"
		13="Sports, Exercise, and Recreation"
		14="Religious and Spiritual Activities"
		15="Volunteer Activities"
		16="Telephone Calls"
		18="Traveling"
		50="Other"
	; 
run;
data secondary_time_by_activity; 
	set 
		temp
	; 
	keep 
		TUTIER1CODE 
		euedur24 
		TotalTime
	;
	by 
		TUTIER1CODE
	; 
	if 
		First.TUTIER1CODE=1 
	then 
		TotalTime=0
	;
		TotalTime+euedur24
	;
	if 
		Last.TUTIER1CODE=1
	;
	format 
		TUTIER1CODE activity.
	;
	drop 
		euedur24
	;
run;

proc sort 
	data=
		secondary_time_by_activity 
	out= 
		sorted_secondary_time_by_activity
	; 
	by
		TotalTime
	;
run;

proc sgplot data=secondary_time_by_activity;
	vbar TUTIER1CODE/response=TotalTime;
	format TUTIER1CODE activity.; 
run;

*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;

/*
Note: Perform two-sample t-test(duration) on the columns EUEXERCISE and 
ERTSEAT of resp_act_file_2014_v3. 

Limitations: Several entries in ERTSEAT are coded as negative values
which seems to be illogical. However, those entries indicate "unanswered" or 
blank values, which can be removed prior to analyzing data.

Methodology: Use proc sort to create a temporary sorted table in asscending
order by euexercise, then use Wilcoxon Signed Rank Test from PROC NPAR1WAY 
to compare the secondary eating time in exercise and non-exercise groups. 
PROC UNIVARIATE to check for normality assumption. 

Follow-up: Use historical data to further elaborate on this research question. 
Another option is to use line graph on data from previous year to study the 
trend in secondary eating duration of exercise and non-exercise people.
*/ 
title1 justify=left;
"Question 3 of 3: Are people who exercise less likely to engage in secondary
eating compared to folks that do not?";
				 
title2 justify=left
"Rationale: By statistically prove that exercise can positively affect the habit 
of secondary eating, we can promote the idea and encourage people to do more
physical activities.";

title3 justify=left
"Wilcoxon Sum Ranked Test for euexercise and ertseat"; 

footnote1 justify=left
"The p-value is  _____.";



proc sgplot data=exercise; 
	title
		"Boxplot of EARTSEAT by EUEXERCISE"
	; 
	vbox 
		ertseat/ category=euexercise; 
run;

proc sort 
	data=
		resp_activity_2014_file_v3 
	out=
		exercise
	 ; 
	where 
		euexercise > 0 and ertseat >0
	;
	by 
		euexercise
	;
run;

proc univariate data=exercise normal;
	title 
		"Test for normality";	
	by 
		euexercise
	;
	var 
		ertseat
	;
	qqplot /normal (mu=est sigma=est);
run;

proc NPAR1WAY 
	data=
		exercise wilcoxon
	; 
	class 
		euexercise
	; 
	var 
		ertseat
	; 
	exact wilcoxon; 
run;


