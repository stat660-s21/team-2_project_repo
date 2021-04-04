

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
Question 1 of 3: What type(s) of activities lead to secondary eating?
Rationale: Knowing which type(s) of activities increase(s) the likelihood of secondary eating could help devise preventive strategies.
Note: 
*/


*******************************************************************************;
* Research Question 2 Analysis Starting Point;
*******************************************************************************;
/*
Question 2 of 3: Is there an inverse of proportional relationship between primary and seconday eating among and within household?
Rationale: By answering this question helps generalize common eating habits of people.
*/


*******************************************************************************;
* Research Question 3 Analysis Starting Point;
*******************************************************************************;
/*
Question 3 of 3: Is there a significant difference in secondary eating (both in duration and frequency) among people who exercise and who do not?
Rationale: By statistically prove that exercise can positivel affect the habit of secondary eating, we can promote the idea and encourage people to do more physical activities 
*/
