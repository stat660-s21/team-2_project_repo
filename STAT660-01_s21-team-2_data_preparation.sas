*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

/* 
[Dataset 1 Name] ehact_2014

[Dataset Description] Eating & Health (EH) respondent file

[Experimental Unit Description] Survey Respondents

[Number of Observations] 12,719  
 
[Number of Features] 5

[Data Source] https://www.kaggle.com/bls/eating-health-module-dataset
*/
%let inputDataset1DSN = ehact_2014_raw;
%let inputDataset1URL =
https://raw.githubusercontent.com/stat660/team-2_project_repo/main/data/ehact_2014.csv
;
%let inputDataset1Type = csv;


/* 
[Dataset 2 Name] ehresp_2014

[Dataset Description] The EH Activity file, which contains information such as 
the activity number, whether secondary eating occurred during the activity, and 
the duration of secondary eating. There are 5 variables.

[Experimental Unit Description] Survey Respondents

[Number of Observations] 11,212     

[Number of Features] 37

[Data Source] https://www.kaggle.com/bls/eating-health-module-dataset
*/
%let inputDataset2DSN = ehresp_2014_raw;
%let inputDataset2URL =
https://raw.githubusercontent.com/stat660/team-2_project_repo/main/data/ehresp_2014.csv
;
%let inputDataset2Type = csv;


/* 
[Dataset 2 Name] ehwgts_2014

[Dataset Description] The EH Activity file, which contains information such as 
the activity number, whether secondary eating occurred during the activity, 
and the duration of secondary eating. There are 5 variables.

[Experimental Unit Description] Survey Respondents

[Number of Observations] 11,212   
 
[Number of Features] 161

[Data Source] https://www.kaggle.com/bls/eating-health-module-dataset
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

/* For ehact_2014_raw tucaseID and tuactivity_n form a composite key so any rows
correpsonding to multiple values should be removed. In addition, rows should be 
removed if they are missing values for any of the composite key columns.

After running the proc sort step below, the new dataset ehact_2014 will have no
duplicate/repeated unique id values, and all unique id values will correspond
to our experimental units of interest, which are a single person from a 
specific household identified by tucaseID. This means thecolumns tucaseID and 
tuactivity_n are guaranteed to form a composite key.
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

/* For ehresp_2014_raw the column tucaseID is a primary key so any rows
corresponding to multiple values should be removed. In addition, rows should be
removed if they are missing values for tucaseID.

After running the proc sort step below, the new dataset ehresp_2014 will have
no duplicate/repeated unique id values, and all unique id values will correspond
to our experimental unit of interest, which are United States households. This
means the column tucaseID in ehresp is guaranteed to be a primary key.
*/
proc sort
        nodupkey
		data=ehresp_2014_raw
		dupout=ehresp_2014_raw_dups
		out=ehresp_2014_households
    ;
	where
	    /* remove rows with missing primary key */
	    not(missing(tucaseID))
    ;
    by
	    tucaseid
	;
run;
 
