*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/* 
[Dataset 1 Name] ehact_2014

[Dataset Description] Eating & Health (EH) respondent file

[Experimental Unit Description] The EH Activity file, which contains information 
such as the activity number, whether secondary eating occurred during the 
activity, and the duration of secondary eating. There are 5 variables.

[Number of Observations] 12,719  
 
[Number of Features] 5

[Data Source] This file was downloaded from
https://www.kaggle.com/bls/eating-health-module-dataset in an archive.

[Data Dictionary] http://www.bls.gov/tus/ehmintcodebk1416.pdf

[Unique ID Schema] The columns "tucaseid" and "tuactivity_n" form a composite
key which corresponds to a member of a unique family based on tucaseid and their
eating activities.

*/
%let inputDataset1DSN = ehact_2014_raw;
%let inputDataset1URL =
https://raw.githubusercontent.com/stat660/team-2_project_repo/main/data/ehact_2014.csv
;
%let inputDataset1Type = csv;


/* 
[Dataset 2 Name] ehresp_2014

[Dataset Description] The EH Respondent file, which contains information about 
EH respondents, including general health and body mass index. There are 37 
variables. TucaseID is 1 since only one family member response from each family
was record.

[Experimental Unit Description] Unique Family Survey Respondent

[Number of Observations] 11,212     

[Number of Features] 37

[Data Source] This file was downloaded from
https://www.kaggle.com/bls/eating-health-module-dataset in an archive.

[Data Dictionary] http://www.bls.gov/tus/ehmintcodebk1416.pdf

[Unique ID Schema] The columns "tucaseid" and "tulineno" form a composite key
which correposnds to a member of a unique family responding to the survey.
*/
%let inputDataset2DSN = ehresp_2014_raw;
%let inputDataset2URL =
https://raw.githubusercontent.com/stat660/team-2_project_repo/main/data/ehresp_2014.csv
;
%let inputDataset2Type = csv;


/* 
[Dataset 2 Name] ehwgts_2014

[Dataset Description] The EH Replicate weights file, which contains 
miscellaneous EH weights. There are 161 variables.

[Experimental Unit Description] Survey Respondents

[Number of Observations] 11,212   
 
[Number of Features] 161

[Data Source] This file was downloaded from
https://www.kaggle.com/bls/eating-health-module-dataset in an archive.

[Data Dictionary] http://www.bls.gov/tus/ehmintcodebk1416.pdf

[Unique ID Schema] The column tucase id is a unique key.
*/
%let inputDataset3DSN = ehwgts_2014_raw;
%let inputDataset3URL =
https://raw.githubusercontent.com/stat660/team-2_project_repo/main/data/ehwgts_2014.csv
;
%let inputDataset3Type = csv;


/* load raw datasets over the wire, if they doesn't already exist */
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            %put Loading dataset &dsn. over the wire now...;
            filename
                tempfile
                "%sysfunc(getoption(work))/tempfile.&filetype."
            ;
            proc http
                    method="get"
                    url="&url."
                    out=tempfile
                ;
            run;
            proc import
                    file=tempfile
                    out=&dsn.
                    dbms=&filetype.
                ;
            run;
            filename tempfile clear;
        %end;
    %else
        %do;
            %put Dataset &dsn. already exists. Please delete and try again.;
        %end;
%mend;
%macro loadDatasets;
    %do i = 1 %to 3;
        %loadDataIfNotAlreadyAvailable(
            &&inputDataset&i.DSN.,
            &&inputDataset&i.URL.,
            &&inputDataset&i.Type.
        )
    %end;
%mend;
%loadDatasets

/* For ehact_2014_raw the columns tucaseID and tuactivity_n form a composite 
key so any rowscorrepsonding to multiple values should be removed. In addition,
rows should be removed if they are missing values for any of the composite key
columns.

After running the proc sort step below, the new dataset ehact_2014 will have no
duplicate/repeated unique id values, and all unique id values will correspond
to our experimental units of interest, which are the eating activities of
a person from a family. This means thecolumns tucaseID and tuactivity_n are 
guaranteed to form a composite key.
*/
proc sort
	nodupkey
	data=ehact_2014_raw
	dupout=ehact_2014_raw_dups
	out=ehact_2014_households
	;
	where
	/* remove rows with missing composite key components */
	not(missing(tucaseid))
	and
	not(missing(tuactivity_n))
	;
    by 
        tucaseid
		tuactivity_n
	;
run;

/* For ehresp_2014_raw the columns tucaseID and tulineno form a composite key 
so any rowscorresponding to multiple values should be removed. In addition, 
rows should be removed if they are missing values for tucaseID.

After running the proc sort step below, the new dataset ehresp_2014 will have
no duplicate/repeated unique id values, and all unique id values will correspond
to our experimental unit of interest, which are a member of a unique household in
the United states. This means the columns tucaseid and tulineno in ehresp are 
guaranteed to form a primary key.
*/
proc sort
	nodupkey
	data=ehresp_2014_raw
	dupout=ehresp_2014_raw_dups
	out=ehresp_2014_households
	;
	where
	    /* remove rows with missing composite key components */
		not(missing(tucaseid))
		and
		/*remove rows for missing family person id number */
		not(missing(tulineno)
	;
    by
		tucaseid
		tulineno
	;
run;
 

/*
For ehwgts_2014_raw, the column tucaseid is a primary key, so any rows
corresponding to multiple values should be removed. In addition, rows should
be removed if they are missing values for tucaseid.

After running the proc sort step below, the new dataset ehwgts_2014 will have
no duplicate/repeated unique id values, and all unique id values will
correspond to our experiment unit of interest, which are individuals
in unique U.S. families.
*/
proc sort
	nodupkey
	data=ehwgts_2014_raw
	dupout=ehwgts_2014_raw_dups
	out=ehwgts_2014
	;
	where
	    /* remove rows with missing primary key */
		not(missing(tucaseID))
	;
    by
		tucaseid
	;
run;

/* Data will be extracted and combined from two of the data files and combined
into a large table. The columns needed from ehresp_2014_raw are "tucaseid",
"ertpreat", "erseat", "euexercise", "erincome", "erbmi", and "euexercise". The
columns neded from ehact_2014_raw are "tucaseid", "euedur24", and "tuactivity"

After executing the following code. A new data table will be created which will
then be passed to an additional step to check for duplicate entries and remove
them if found. */

data resp_actvity_2014_file_v1;
	retain
		tucaseid
		ertpreat
		erseat
		euexercise
		erincome
		erbmi
		euexercise
		euedur24
		tuactivity_n
	;
	keep
		tucaseid
		ertpreat
		erseat
		euexercise
		erincome
		erbmi
		euexercise
		euedur24
		tuactivity_n
	;
	merge
		ehresp_2014_raw
		ehact_2014_raw
	;
	by
		tucaseid
	;
run;


data resp_actvity_2014_file_v2(	
	drop=
		tucaseid_int
	);
	retain
		tucaseid
		tucaseid_n
		ertpreat
		erseat
		euexercise
		erincome
		erbmi
		euexercise
		euedur24 
	;
	set resp_actvity_2014_file_v1(
		rename=(
			tucaseid=tucaseid_int
			)
		);
	tucaseid=put(tucaseid_int, z14.);
run;

proc print 
	data= resp_actvity_2014_file_v2 (obs=15); 
run;

/*Prior to running the proc sort, we already expect duplicates in tucaseid since 
the ehact_2014_raw was in long format instead of wide format. Therefore when 
activities and respondents file are merged, the final dataset also has long format 
with repeated tucaseid for each tucaseid_n activity listed in ehact_2014_raw.*/

proc sort
	nodupkey
	data=resp_actvity_2014_file_v2
	dupout=resp_actvity_2014_file_v2_dups
	out=resp_actvity_2014_file_v3
	;
	where
	    /* remove rows with missing primary key */
		not(missing(tucaseID))
	;
    by
		tucaseid
	;
run;

proc print 
	data= resp_actvity_2014_file_v3 (obs=15); 
run;

