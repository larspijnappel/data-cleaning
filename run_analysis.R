## author   : lars.pijnappel@gmail.com
## date     : 14 August 2016


#### Initialize ####
rm(list=ls())

## Due to data sizes, package `data.table` comes to the rescue when importing and handling the data sets. 
## And what would we do without the `dplyr` package...

library(data.table)
## find the data.table cheat sheet at
## https://www.r-bloggers.com/the-data-table-cheat-sheet/

library(dplyr)
## find the dplyr & tidyr data wrangling cheat sheet at 
## https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf




#### Download source data ####

## perform the following steps:
## 1. download source file
## 2. unpack the zipped archive

## 1. Download and unpack the source data in a separate directory PGA (Peer Graded Assignment).
dir_project <- 'PGA_lp'
if ( !dir.exists( dir_project ) ) dir.create( dir_project )

url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
## determine filename for downloaded zip file
fpn <- paste( dir_project, basename( url ), sep = '/' )
download.file( url, dest = fpn, mode = 'wb' )

## 2. unpack the zip file in the wd directory. Unpacked files are located in './PGA/UCI HAR Dataset'
unzip( zipfile = fpn, exdir = dir_project )




#### Import relevant Files ####

## import files containing the:
## 1. Activities (which maps the activity ID with its description) 
## 2. Features   (which will be mapped as variable names on the imported training & test data sets)
## Results are stored in `DT_activity` and `DT_features` respectively.

dir_import <- paste( dir_project, 'UCI HAR Dataset', sep = '/')

### 1. import activities
fpn <- paste( dir_import, 'activity_labels.txt', sep = '/' )
DT_activity <- fread( fpn )
setnames( DT_activity, c('V1', 'V2'), c( 'activity_id', 'activity' ) )

### 2. import features list
fpn <- paste( dir_import, 'features.txt', sep = '/' )
DT_features <- fread( fpn, drop = 'V1' )      ## drop the first column as it's one-on-one with the row-nrs 
## renaming variable names has no added value

# ## /!\ beware that this list of features contain duplicate names:
# DT_feat[ which(duplicated(DT_feat)),]




#### Import & Merge Test Data ####

## 1. Import the test set related files, i.e.:
##     a. Test set
##     b. Test labels
##     c. Subject ID's
##    Rename variable names for test labels and subject only 
##     - test set variables will be renamed later in the process
## 2. Merge the related files for the test set into `DT_test`

## 1.a import test set
fpn <- paste( dir_import, 'test/X_test.txt', sep = '/' )
DT_X <- fread( fpn )
# ## inspect the imported data visualy with the source data
# DT_X[ , .(V1, V561) ]    ## show first and last 5 rows of the first (V1) and last (v561) column

## 1.b import test labels
fpn <- paste( dir_import, 'test/y_test.txt', sep = '/' )
DT_y <- fread( fpn )
setnames( DT_y, "V1", "activity_id" )[]  ## results are printed by adding [] after the set function

## 1.c import subjects
fpn <- paste( dir_import, 'test/subject_test.txt', sep = '/' )
DT_subj <- fread( fpn )
setnames( DT_subj, "V1", "subject")
# ## show the total observations per subject
# table(DT_subj)

## 2. merge all test data into one
DT_test <- data.table( DT_subj, DT_y, DT_X )
# as.data.table(names(DT_test))

# ### check results (DT_test) with the 3 input files
# ### show the first 3 + last variables
# ### for the top & bottom 5 observations
# DT_test[, .(subject, activity_id, V1, V561) ]
# ### another approach, same result
# select( DT_test, c(1:3, NCOL(DT_test)))




#### Import & Merge Training Data ####

## same steps as for the Test Data set as described above

## 1.a import training set
fpn <- paste( dir_import, 'train/X_train.txt', sep = '/' )
DT_X <- fread( fpn )
# ## inspect the imported data visualy with the source data
# DT_X[ , .(V1, V561) ]    ## show first and last 5 rows of the first (V1) and last (v561) column

## 1.b import train labels
fpn <- paste( dir_import, 'train/y_train.txt', sep = '/' )
DT_y <- fread( fpn )
setnames( DT_y, "V1", "activity_id" )[]  ## results are printed by adding [] after the set function

## 1.c import subjects
fpn <- paste( dir_import, 'train/subject_train.txt', sep = '/' )
DT_subj <- fread( fpn )
setnames( DT_subj, "V1", "subject")
# ## show the total observations per subject
# table(DT_subj)

## 2. merge all train data into one
DT_train <- data.table( DT_subj, DT_y, DT_X )
# as.data.table(names(DT_train))

# ### check results (DT_train) with the 3 input files
# ### show the first 3 + last variables
# ### for the top & bottom 5 observations
# DT_train[, .(subject, activity_id, V1, V561) ]
# ### another approach, same result
# select( DT_train, c(1:3, NCOL(DT_train)))




#### Merge Test & Train data ####

## perform the following steps:
## 1. merge both data sets
## 2. remove obsolete objects

## 1. merge the test and training data sets into one data set `DT_all`
l <- list( DT_test, DT_train )
DT_all <- rbindlist( l )
# NROW( DT_test ) + NROW( DT_train ) == NROW( DT_all )
# ## visually check the first and last observation for the test and train sets
# select( DT_all[ c(1,2947, 2948, 10299),], c(1:3,563) )

## 2. remove obsolete objects
rm( DT_X, DT_y, l )




#### Tidy Test Data ####

## Following objects are ready for further processing:
## - DT_all         (containing the test and training set data)
## - DT_activity    (containing the mapping of activity ID and description)
## - DT_features    (containing the features which need to be mapped onto the 561 variable names of DT_all)

## Perform following steps:
## 1. Include the correct activity name to each observation
## 2. Reorder the variable names and remove the obsolete activity_id variable
## 3. Rename the V1-V561 variable names by mapping them onto the feature list 

## 1. merge DT_activity into DT_all
## before performing a join, a key must be set with which the join can be performed (table will be sorted as a result!)
setkey( DT_all, activity_id )
## merge DT_activity with DT_all by performing a join
DT_all <- DT_all[DT_activity]
# DT_all[, .(subject, activity_id, activity ) ]
# table(DT_all[,.(activity, activity_id)] )  ## check if join shows expected stats

## 2. Reorder the variables
### place activity_id + activity before the rest
DT_all <- select( DT_all, subject, starts_with('activity'), everything() )
# as.data.table( names(DT_all) )
## remove the obsolete activity_id, as the activity labels are included in the data set
DT_all[, activity_id := NULL ]
# as.data.table( names(DT_all) )

## 3. rename the 'feature' variables
## /!\ beware that the list of features contain duplicate names.
## /!\ mapping these features onto the 561 variables results in duplicate variable names ..
setnames( DT_all, 3:563, c(DT_features$V2) )
# as.data.table( names(DT_all) )




#### Final Tidy Data Set ####

## Perform following steps:
## 1. determine feature variables as per requirement #2 of the project assignment
## 2. create DT_tidy, which matches the requirements and ready for export
## 3. export to TXT file

## 1. first determine which variables from DT_all need to be included in the final dataset DT_tidy
## According to requirement 2 of the project assignment:
## - "Extract only the measurements on the mean and standard deviation for each measurement."
## do this by searching the DT_features list for feature variables containing 'mean()' or 'std()'
feat_var <- DT_features[ grep( "mean\\(\\)|std\\(\\)" , DT_features$V2 ) ]
# ## as the feature list contains duplicate values, doublecheck if that's not the case for the found values.
# table(duplicated( feat_var ))     ## 66 unique variable names found
feat_var <- unlist( c(feat_var) )   ## convert feat_var into a character class so that .SDcols can handle it properly
## these selected feature values become the new variable names in the DT_final set

## 2. create DT_tidy
## usage of .SD and .SDcols (as specified in the data.table cheat sheet):
## - .SD is a data.table and holds all the values of all columns, except the one specified in by.
## - .SDcols is used together with .SD, to specify a subset of the columns of .SD to be used in j. 

## Following command applies the mean() function on all feat_var columns (.SDcols) for each activity+subject (by). 
## - lapply(.SD, mean)            > calculate the mean for each column (except the one specified in by).
## - by = .(activity, subject)    > group j by column activity and subject, then calculate j
## - .SDcols = feat_var           > specifies the columns on which to act on
DT_tidy <- DT_all[ ,lapply(.SD, mean), by = .(activity, subject), .SDcols = feat_var ]

## first check by means of dimensions:
dim(DT_tidy)
## NROW = 180   > 30 subjects, each having 6 activities
## NCOL = 68    > 66 feat_var (matching the feaure requirements) + 1 subject + 1 activity

## 3. export the final data set DT_tidy to a text file for upload to the Coursera site.
write.table( DT_tidy, file = paste( dir_project, "DT_tidy-step5.txt", sep = '/'), row.names = F)
