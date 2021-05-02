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

title1" What type(s) of activities are more likely to be associated 
with secondary eating?";

title2 "Rationale: Knowing which type(s) of activities increase(s) the likelihood of 
secondary eating could help devise preventive strategies.";
		   
footnote1" Perform one-way ANOVA with EUEDUR24 as the response variable and 
TUACTIVITU_N as factors"

footnote2" Many entries in EUEDUR24 are coded -1 which seems to be illogical. 
However, those entries indicate "unanswered" or missing values, which can be 
removed prior to analyzing data";


*Creating common format for values in 3 data sets;
proc format; 
	value miss 
		-1,-2,-3= "invalid"
		;
run;

proc print data=resp_activity_2014_file_v3;run;
 
title3 "Test for normality";
proc sort data=resp_activity_2014_file_v2 out=sorted; 
	where euedur24 ge 0;
	by 
		tuactivity_n
	; 
run;


proc contents data=sorted; 
run;
data sorted; 
	set sorted; 
	if tuactivity_n< 100 then tuactivity=100;
	else tuactivity=tuactivity_n;
run;
proc freq data=sorted order=freq; 
	table tuactivity_n/out=temp noprint; 
run;
*proc print data=temp;run;
data temp ; 
	set temp; 
		if Count <100 then tuactivity='other'; 
		else tuactivity=tuactivity_n;
	keep tuactivity_n tuactivity;
run;

proc print data=temp;run;


proc print data=sorted(obs=200);run;

data a; 
	set sorted; 
	if tuactivity_n in (1,24-56) then tuactivity=100;
	else tuactivity=tuactivity_n;
run;

proc print data=a;
run;

proc univariate data=sorted normal;
	by 
		tuactivity_n
	;
	var 
		euedur24
	;
	qqplot /normal (mu=est sigma=est);
run;


 
title4 "Test for equality of variances and perform anova";
proc glm data=resp_actvity_2014_file_v3;
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
title;
footnote;

*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;

title1" Is there a relationship between primary and seconday eating 
among households?";
				 
title2"Rationale: By answering this question helps generalize common eating habits 
of people.";

footnote1" Find the correlation between the columns ERTPREAT and ERTSEAT of 
ehresp_2014_raw";

footnote2" Several entries in ERTPREAT and ERTSEAT are coded as negative values
which seems to be illogical. However, those entries indicate "unanswered" or 
blank values, which can be removed prior to analyzing data.";

title3 "Frequency tables of primary and secondary eating";
proc freq data=resp_actvity_2014_file_v3 nlevels;
	table 
		ERTPREAT ERTSEAT;
	format 
		ERTSEAT miss.;
run;

proc corr data=resp_actvity_2014_file_v3; 
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
proc freq data=resp_activity_2014_file_v3; 
	where euexercise NOTIN (-1,-2,-3) and ertseat NOTIN (-1,-2,-3);
	table euexercise*ertseat/ nocum norow nocol nopercent;
run;
	
title;

proc sgplot data=resp_activity_2014_file_v3; 
	format 
		euexercise miss.;
	vbox 
		ertseat/ category=euexercise; 
run;


proc contents data=resp_activity_2014_file_v3; run;
