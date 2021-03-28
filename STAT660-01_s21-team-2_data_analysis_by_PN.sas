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
Question 1 of 3: What are the top five schools that experienced the biggest
increase in "Percent (%) Eligible Free (K-12)" between AY2014-15 and AY2015-16?
Rationale: This should help identify schools to consider for new outreach based
upon increasing child-poverty levels.
Note: 
*/


*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 3: 
Rationale: 
*/


*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: 
Rationale: 
Note: 
*/
