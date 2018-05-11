Loading a small 11.2gb SAS dataset into R in under eight minutes;


https://stackoverflow.com/questions/50243600/loading-large-sas-file-in-r-gives-error-cannot-allocate-vector-of-size-109-3-m


 Keep in mind that R can only handle 2**31 elements in any vector, matrix or array

 Algorithm (16gb old dell laptop)

    1. Split large dataset into two datasets, one with a all numerics
       and another with all character.
    2. For the numeric dataset, output back to back floats into a binary file.
    3. Load the floats as is using readBin in R. No expensive conversions needed. very fast.
    4. Use have read_sas to load the character data.


INPUT
=====

11.2 gb dataset with14,000,000 observations and 122 variables 76 numeric and 46 character

 NAME         TYPE      NAME      TYPE     NAME           TYPE    NAME           TYPE

 AGE            N      DX25        C       E_CCS3           N     PR15             C
 AWEEKEND       N      DXCCS1      N       E_CCS4           N     PRCCS1           N
 DIED           N      DXCCS2      N       FEMALE           N     PRCCS2           N
 DISCWT         N      DXCCS3      N       HCUP_ED          N     PRCCS3           N
 DISPUNIFORM    N      DXCCS4      N       HOSP_NRD         N     PRCCS4           N
 DMONTH         N      DXCCS5      N       KEY_NRD          N     PRCCS5           N
 DQTR           N      DXCCS6      N       LOS              N     PRCCS6           N
 DRG            N      DXCCS7      N       MDC              N     PRCCS7           N
 DRGVER         N      DXCCS8      N       MDC_NOPOA        N     PRCCS8           N
 DRG_NOPOA      N      DXCCS9      N       NCHRONIC         N     PRCCS9           N
 DX1            C      DXCCS10     N       NDX              N     PRCCS10          N
 DX2            C      DXCCS11     N       NECODE           N     PRCCS11          N
 DX3            C      DXCCS12     N       NPR              N     PRCCS12          N
 DX4            C      DXCCS13     N       NRD_DAYSTOEVENT  N     PRCCS13          N
 DX5            C      DXCCS14     N       NRD_STRATUM      N     PRCCS14          N
 DX6            C      DXCCS15     N       NRD_VISITLINK    C     PRCCS15          N
 DX7            C      DXCCS16     N       ORPROC           N     REHABTRANSFER    N
 DX8            C      DXCCS17     N       PAY1             N     RESIDENT         N
 DX9            C      DXCCS18     N       PL_NCHS          N     SAMEDAYEVENT     C
 DX10           C      DXCCS19     N       PR1              C     TOTCHG           N
 DX11           C      DXCCS20     N       PR2              C     YEAR             N
 DX12           C      DXCCS21     N       PR3              C     ZIPINC_QRTL      N
 DX13           C      DXCCS22     N       PR4              C
 DX14           C      DXCCS23     N       PR5              C
 DX15           C      DXCCS24     N       PR6              C
 DX16           C      DXCCS25     N       PR7              C
 DX17           C      ECODE1      C       PR8              C
 DX18           C      ECODE2      C       PR9              C
 DX19           C      ECODE3      C       PR10             C
 DX20           C      ECODE4      C       PR11             C
 DX21           C      ELECTIVE    N       PR12             C
 DX22           C      E_CCS1      N       PR13             C
 DX23           C      E_CCS2      N       PR14             C
 DX24           C

EXAMPLE R DATA

  NUMERIC R DATA

    14,000,000 row of 76 variables with correct names

    num [1:14000000, 1:76] 24 8 38 9 25 8 3 10 44 14 ...

    - attr(*, "dimnames")=List of 2
     ..$ : NULL
     ..$ : chr [1:76] "AGE" "AWEEKEND" "DIED" "DISCWT" ..

  CHARACTER R DATA

    14,000,000 row of 46 variables with correct names

     Classes 'tbl_df', 'tbl' and 'data.frame':	14000000 obs. of  46 variables:
      $ DX1          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX2          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX3          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX4          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX5          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX6          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX7          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX8          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX9          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
     ...
     ...
      $ PR12         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR13         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR14         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR15         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ SAMEDAYEVENT : chr  "AB" "AB" "AB" "AB" ...


PROCESS (WORKING CODE)
======================

  NUMERIC

    names_nums<-read_sas("d:/sd1/names_nums.sas7bdat");
    read.from <- file("d:/bin/binmat.bin", "rb");
    floats <- readBin(read.from, n=14000000*76, "double");
    floats <- matrix(floats, nrow=14000000,ncol=76);
    colnames(floats)<-colnames(names_nums);

  CHARACTER

    library(haven);
    chars<-read_sas("d:/sd1/values_chrs.sas7bdat");


OUTPUT
=======

  NUMERIC R DATA

    14,000,000 row of 76 variables with correct names

    num [1:14000000, 1:76] 24 8 38 9 25 8 3 10 44 14 ...

    - attr(*, "dimnames")=List of 2
     ..$ : NULL
     ..$ : chr [1:76] "AGE" "AWEEKEND" "DIED" "DISCWT" ..

  CHARACTER

     Classes 'tbl_df', 'tbl' and 'data.frame':	14000000 obs. of  46 variables:

      $ DX1          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX2          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX3          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX4          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX5          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX6          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX7          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX8          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX9          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX10         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX11         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX12         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX13         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX14         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX15         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX16         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX17         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX18         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX19         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX20         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX21         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX22         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX23         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX24         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ DX25         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ ECODE1       : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ ECODE2       : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ ECODE3       : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ ECODE4       : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ NRD_VISITLINK: chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
      $ PR1          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR2          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR3          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR4          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR5          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR6          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR7          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR8          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR9          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR10         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR11         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR12         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR13         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR14         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ PR15         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
      $ SAMEDAYEVENT : chr  "AB" "AB" "AB" "AB" ...

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

libname sd1 "d:/sd1";

 * split into numeric and char variable;
data  sd1.values_nums(keep=_numeric_) sd1.values_chrs(keep=_character_)
      sd1.names_nums(keep=_numeric_) ;
length
    AGE 8 AWEEKEND 8 DIED 8 DISCWT 8 DISPUNIFORM 8 DMONTH 8 DQTR 8 DRG 8
    DRGVER 8 DRG_NoPOA 8 DX1 $5 DX2 $5 DX3 $5 DX4 $5 DX5 $5 DX6 $5 DX7 $5
    DX8 $5 DX9 $5 DX10 $5 DX11 $5 DX12 $5 DX13 $5 DX14 $5 DX15 $5 DX16 $5
    DX17 $5 DX18 $5 DX19 $5 DX20 $5 DX21 $5 DX22 $5 DX23 $5 DX24 $5 DX25 $5
    DXCCS1 8 DXCCS2 8 DXCCS3 8 DXCCS4 8 DXCCS5 8 DXCCS6 8 DXCCS7 8 DXCCS8 8
    DXCCS9 8 DXCCS10 8 DXCCS11 8 DXCCS12 8 DXCCS13 8 DXCCS14 8 DXCCS15 8
    DXCCS16 8 DXCCS17 8 DXCCS18 8 DXCCS19 8 DXCCS20 8 DXCCS21 8 DXCCS22 8
    DXCCS23 8 DXCCS24 8 DXCCS25 8 ECODE1 $5 ECODE2 $5 ECODE3 $5 ECODE4 $5
    ELECTIVE 8 E_CCS1 8 E_CCS2 8 E_CCS3 8 E_CCS4 8 FEMALE 8 HCUP_ED 8
    HOSP_NRD 8 KEY_NRD 8 LOS 8 MDC 8 MDC_NoPOA 8 NCHRONIC 8 NDX 8 NECODE 8
    NPR 8 NRD_DaysToEvent 8 NRD_STRATUM 8 NRD_VisitLink $6 ORPROC 8 PAY1 8
    PL_NCHS 8 PR1 $4 PR2 $4 PR3 $4 PR4 $4 PR5 $4 PR6 $4 PR7 $4 PR8 $4 PR9
    $4 PR10 $4 PR11 $4 PR12 $4 PR13 $4 PR14 $4 PR15 $4 PRCCS1 8 PRCCS2 8
    PRCCS3 8 PRCCS4 8 PRCCS5 8 PRCCS6 8 PRCCS7 8 PRCCS8 8 PRCCS9 8 PRCCS10
    8 PRCCS11 8 PRCCS12 8 PRCCS13 8 PRCCS14 8 PRCCS15 8 REHABTRANSFER 8
    RESIDENT 8 SAMEDAYEVENT $2 TOTCHG 8 YEAR 8 ZIPINC_QRTL 8;
array chrs[*] _character_;
array nums[*] _numeric_;
do rec=1 to 14000000;
   do i=1 to dim(nums);
     nums[i]=int(100*uniform(1234));
   end;
   do i=1 to dim(chrs);
     chrs[i]="ABCDE";
   end;
   drop rec i;
   if rec=1 then output sd1.names_nums ;    * one ob of names;
   output sd1.values_nums sd1.values_chrs;
end;
stop;
run;quit;

/*
NOTE: The data set SD1.VALUES_NUMS has 14000000 observations and 76 variables. 8.3gb
NOTE: The data set SD1.VALUES_CHRS has 14000000 observations and 46 variables. 2.9gb
NOTE: The data set SD1.NAMES_NUMS has 1 observations and 76 variables.        11.2gb
NOTE: DATA statement used (Total process time):
      real time           47.09 seconds
*/

* send to back to back floats 7*46=608;
filename bin "d:/bin/binmat.bin" lrecl=608 recfm=f;
data _null_;
  set sd1.values_nums;
  file bin;
  put (_all_) (rb8.);
run;quit

/*
NOTE: 14000000 records were written to the file BIN.
NOTE: There were 14000000 observations read from the data set SD1.VALUES_NUMS.
NOTE: DATA statement used (Total process time):
      real time           26.92 seconds
*/

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%utl_submit_r64('
    memory.limit(size=64000);
    source("C:/Program Files/R/R-3.3.1/etc/Rprofile.site", echo=T);
    library(haven);
    names_nums<-read_sas("d:/sd1/names_nums.sas7bdat");
    read.from <- file("d:/bin/binmat.bin", "rb");
    floats <- readBin(read.from, n=14000000*76, "double");
    floats <- matrix(floats, nrow=14000000,ncol=76);
    colnames(floats)<-colnames(names_nums);
    str(floats);
');

> options(help_type = "html")
 num [1:14000000, 1:76] 24 8 38 9 25 8 3 10 44 14 ...
 - attr(*, "dimnames")=List of 2
  ..$ : NULL
  ..$ : chr [1:76] "AGE" "AWEEKEND" "DIED" "DISCWT" ..
>

/*
NOTE: DATA statement used (Total process time):
      real time           2:15.20
      cpu time            0.01 seconds
*/


%utl_submit_r64('
    source("C:/Program Files/R/R-3.3.1/etc/Rprofile.site", echo=T);
    library(haven);
    chars<-read_sas("d:/sd1/values_chrs.sas7bdat");
    str(chars);
');

Classes 'tbl_df', 'tbl' and 'data.frame':	14000000 obs. of  46 variables:
 $ DX1          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX2          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX3          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX4          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX5          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX6          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX7          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX8          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX9          : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX10         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX11         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX12         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX13         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX14         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX15         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX16         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX17         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX18         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX19         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX20         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX21         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX22         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX23         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX24         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ DX25         : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ ECODE1       : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ ECODE2       : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ ECODE3       : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ ECODE4       : chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ NRD_VISITLINK: chr  "ABCDE" "ABCDE" "ABCDE" "ABCDE" ...
 $ PR1          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ PR2          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ PR3          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ PR4          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ PR5          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ PR6          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ PR7          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ PR8          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ PR9          : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ PR10         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ PR11         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ PR12         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ PR13         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ PR14         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ PR15         : chr  "ABCD" "ABCD" "ABCD" "ABCD" ...
 $ SAMEDAYEVENT : chr  "AB" "AB" "AB" "AB" ...
 - attr(*, "label")= chr "VALUES_CHRS"
>
NOTE: 52 lines were written to file PRINT.
Stderr output:
Warning message:
package 'haven' was built under R version 3.3.3
NOTE: 52 records were read from the infile RUT.
      The minimum record length was 0.
      The maximum record length was 150.
NOTE: DATA statement used (Total process time):
      real time           5:55.84


