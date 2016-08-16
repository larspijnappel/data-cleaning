## author   : lars.pijnappel@gmail.com
## date     : 14 August 2016


#### step 1 - Initialisation ####
rm(list=ls())

## Due to data sizes, package `data.table` comes to the rescue when importing and handling the data sets. 
## And what would we do without the `dplyr` and 'tidyr' package...

library(data.table)
## find the data.table cheat sheet at
## https://www.r-bloggers.com/the-data-table-cheat-sheet/

library(dplyr)
library(tidyr)
## find the dplyr & tidyr data wrangling cheat sheet at 
## https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf

## Create a project directory PGA (Peer Graded Assignment) which will be used by this script.
dir_project <- 'PGA_lp'
if ( !dir.exists( dir_project ) ) dir.create( dir_project )



#### step 2 - Get Source Data ####

## Download and unpack the source data in the specified project directory
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
## determine filename for downloaded zip file
fpn <- paste( dir_project, basename( url ), sep = '/' )
download.file( url, dest = fpn, mode = 'wb' )
## unpack the zip file in the same directory.
unzip( zipfile = fpn, exdir = dir_project )


#### step 3 - Import Source Files ####

dir_import <- paste( dir_project, 'UCI HAR Dataset', sep = '/')

##### step 3.1 - Import Meta Files #####

## import files containing the:
## 1. Activities (which maps the activity ID with its description) 
## 2. Features   (which will be mapped as variable names on the imported training & test data sets)
## Results are stored in `DT_activity` and `DT_features` respectively.

### 1. import activities
fpn <- paste( dir_import, 'activity_labels.txt', sep = '/' )
DT_activity <- fread( fpn )
setnames( DT_activity, c('V1', 'V2'), c( 'activity_id', 'activity' ) )

### 2. import features list
fpn <- paste( dir_import, 'features.txt', sep = '/' )
DT_features <- fread( fpn, drop = 'V1' )      ## drop the first column as it's one-on-one with the row-nrs 
## renaming variable names has no added value

# ## /!\ beware that this list of features contain duplicate names.
# ## for example: fBodyAcc-bandsEnergy()-1,8 is listed three times.
# ## For a list of 42 names which are listed more than once:
# unique( DT_features[ which(duplicated(DT_features)),] )


##### step 3.2 - Import Test Data Files #####

## 1. Import the test set related files from the folder 'test', i.e.:
##     a. Test set
##     b. Test labels
##     c. Subject ID's
##    Rename variable names for test labels and subject only 
##     - test set variables will be renamed later in the process
## 2. Merge the related files for the test set into `DT_test`

## import test set
fpn <- paste( dir_import, 'test/X_test.txt', sep = '/' )
DT_X <- fread( fpn )
# ## inspect the imported data visualy with the source data
# DT_X[ , .(V1, V561) ]    ## show first and last 5 rows of the first (V1) and last (v561) column

## import test activity labels
fpn <- paste( dir_import, 'test/y_test.txt', sep = '/' )
DT_y <- fread( fpn )
setnames( DT_y, "V1", "activity_id" )[]  ## results are printed by adding [] after the set function

## import test subjects
fpn <- paste( dir_import, 'test/subject_test.txt', sep = '/' )
DT_subj <- fread( fpn )
setnames( DT_subj, "V1", "subject")
# ## show the total observations per subject
# table(DT_subj)

## merge all test data into one
DT_test <- data.table( DT_subj, DT_y, DT_X )
# as.data.table(names(DT_test))

# ### check results (DT_test) with the 3 input files
# ### show the first 3 + last variables
# ### for the top & bottom 5 observations
# DT_test[, .(subject, activity_id, V1, V561) ]
# ### another approach, same result
# select( DT_test, c(1:3, NCOL(DT_test)))


##### step 3.3 - Import Training Data Files #####

## same steps as for the Test Data set as described above. But now, retrieve input from the folder 'train'

## import training set
fpn <- paste( dir_import, 'train/X_train.txt', sep = '/' )
DT_X <- fread( fpn )
# ## inspect the imported data visualy with the source data
# DT_X[ , .(V1, V561) ]    ## show first and last 5 rows of the first (V1) and last (v561) column

## import train activity labels
fpn <- paste( dir_import, 'train/y_train.txt', sep = '/' )
DT_y <- fread( fpn )
setnames( DT_y, "V1", "activity_id" )[]  ## results are printed by adding [] after the set function

## import train subjects
fpn <- paste( dir_import, 'train/subject_train.txt', sep = '/' )
DT_subj <- fread( fpn )
setnames( DT_subj, "V1", "subject")
# ## show the total observations per subject
# table(DT_subj)

## merge all train data into one
DT_train <- data.table( DT_subj, DT_y, DT_X )
# as.data.table(names(DT_train))

# ### check results (DT_train) with the 3 input files
# ### show the first 3 + last variables
# ### for the top & bottom 5 observations
# DT_train[, .(subject, activity_id, V1, V561) ]
# ### another approach, same result
# select( DT_train, c(1:3, NCOL(DT_train)))




#### step 4 - Merge and Enhance Test + Training Data ####

## merge the test and training data sets into one data set `DT_all`
l <- list( DT_test, DT_train )
DT_all <- rbindlist( l )
# NROW( DT_test ) + NROW( DT_train ) == NROW( DT_all )
# ## visually check the first and last observation for the test and train sets
# select( DT_all[ c(1,2947, 2948, 10299),], c(1:3,563) )

## remove obsolete objects
rm( DT_X, DT_y, l )

## Following objects are ready for further processing:
## - DT_all         (containing the test and training set data)
## - DT_activity    (containing the mapping of activity ID and description)
## - DT_features    (containing the features which need to be mapped onto the 561 variable names of DT_all)

## Perform following steps:
## 4.1 Include the correct activity name to each observation
## 4.2 Reorder the variable names and remove the (now obsolete) activity_id variable
## 4.3 Rename the variable names V1-V561 by mapping them onto the feature list 

## 4.1 include DT_activity variable into DT_all
## before performing a join, a key must be set with which the join can be performed (table will be sorted as a result!)
setkey( DT_all, activity_id )
## merge DT_activity with DT_all by performing a join
DT_all <- DT_all[DT_activity]
# DT_all[, .(subject, activity_id, activity ) ]
# table(DT_all[,.(activity, activity_id)] )  ## check if join shows expected stats

## 4.2 Reorder the variables
### place activity_id + activity before the rest
DT_all <- select( DT_all, subject, starts_with('activity'), everything() )
# as.data.table( names(DT_all) )
## remove the obsolete activity_id, as the activity labels are included in the data set
DT_all[, activity_id := NULL ]
# as.data.table( names(DT_all) )

## 4.3 rename the 'feature' variables
## /!\ beware that the list of features contain duplicate names.
## /!\ mapping these features onto the 561 variables results in duplicate variable names of the data.table ..
setnames( DT_all, 3:563, c(DT_features$V2) )
# as.data.table( names(DT_all) )



#### step 5 - Create & Export Tidy Data Set ####

## steps performed:
## 1. determine feature variables to be included in the tidy data set (see requirement #2 of the project assignment)
## 2. create DT_tidy, which matches the project assignment requirement #2 and # 5
## 3. tidy this dataset into a 'long form'
## 4. export to TXT file

## 1. first determine which variables from DT_all need to be included in the final dataset DT_tidy
## According to requirement 2 of the project assignment:
## - "Extract only the measurements on the mean and standard deviation for each measurement."
## do this by searching the DT_features list for feature variables containing 'mean()' or 'std()'
feat_var <- DT_features[ grep( "mean\\(\\)|std\\(\\)" , DT_features$V2 ) ]
# ## as the feature list contains duplicate values, doublecheck if that's not the case for the found values.
# table(duplicated( feat_var ))     ## No duplicates found: there are 66 unique variable names
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
## NCOL = 68    > 66 feat_var (matching the feature requirements) + 1 subject + 1 activity

## 3. tidy the data set into a long form where 
## each row is an observation for a specific combination of activity + subject + feature
## the gather() function change the class to data.frame. For usability, this is changed to a tbl_df class.
tdf_tidy <- tbl_df( gather( DT_tidy, 'feat_name', 'feat_avg', 3:68 ) )
dim(tdf_tidy)
## 66 features for each subject+activity combination (i.e. 30 subjects each having 6 activities)
## gathering these 66 features results in 11880 rows, where each activity-subject-feat_name is an observation 
## containing the average for that specific feature of the subject's activity.

## sort the tidied data set and export the results
tdf_tidy <- tdf_tidy %>% arrange( activity, subject, feat_name )

## 4. export the final data set DT_tidy to a text file for upload to the Coursera site.
# write.table( DT_tidy, file = paste( dir_project, "DT_tidy-step5.txt", sep = '/'), row.names = F)
write.table( tdf_tidy, file = paste( dir_project, "tdf_tidy-step5.txt", sep = '/'), row.names = F)


#####################################################################

tdf_import <- read.table( paste( dir_project, "tdf_tidy-step5.txt", sep = '/'), header = T, stringsAsFactors = F ) %>% tbl_df()
all.equal( tdf_tidy, tdf_import )

#####################################################################

# library(stringr)
# ## determine unique feature labels (skip first 2 variables activity + subject )
# ## 
# names( DT_tidy )
# x <- str_split( names( DT_tidy )[-(1:2)], "(-(X|Y|Z))")     ## split names by '-X or -Y or -Z'
# unique( as.matrix( lapply( x, head, 1) ) )



## reshape the (wide shape) DT_tidy set into a (narrow shaped) tdf_tidy, 
## by gathering all feature-related columns and their corresponding values into 
## two columns: feat_name and feat_value

library(tidyr)
tdf_tidy <- tbl_df( gather( DT_tidy, 'feat_name', 'feat_value', 3:68 ) )
dim(tdf_tidy)
## 66 features for each subject+activity combination (i.e. 30 subjects each having 6 activities)
## gathering these 66 features results in 11880 rows, where each activity-subject-feat_name is an observation 
## containing the average for that specific feature of the subject's activity.

## sort the tidied data set and export the results
tdf_tidy %>% arrange( activity, subject, feat_name )

# tdf_tidy %>% group_by( activity, subject ) %>% summarise( feat_cnt = n() )
