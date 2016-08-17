---
output: 
  html_document: 
    toc: yes
---
# README data-cleaning

The results of this Peer Graded Assignment for the __Getting and Cleaning Data Course__ contains the following output:

    - README.MD (this file)
    - Tidy Data Set
    - Codebook
    - run_analysis.R
    
## Tidy Data Set

The tidied dataset (`DT_tidy-step5.txt`) can be found on the Coursera site https://www.coursera.org/learn/data-cleaning/peer/FIZtT/getting-and-cleaning-data-course-project/submit

Importing this file can best be done by using the `fread()` function of the `data.table` package. No other parameters than the `input` for the filename is required.

## Codebook

For the tidied data set, the corresponding codebook `code_book.txt` describes details regarding the structure of this data set. This codebook can be found in this Github repo.

## run_analysis.R explained

This script contains the following steps to execute the assignment and produce the output dataset `DT_tidy-step5.txt`. Each of these steps are also explained within the `run_analysis.R` script.

    Execution steps:
    1. Initialisation
    2. Get Source Data
    3. Import Source Files
        1. Import Meta Files
        2. Import Test Data Files
        3. Import Training Data Files
    4. Merge and Enhance Test + Training Data
    5. Create & Export Tidy Data Set


### Step 1 - Initialisation

During initialisation all objects are removed and the packages `data.table` and `dplyr` will be loaded. When needed, a new project directory `PGA_lp` is created in which the input and output files are stored.


### Step 2 - Get Source Data

The source data will be downloaded and extracted from the (as specified) url https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip


### Step 3 - Import Source Files

Before starting to load all needed files, the import directory is determined. The source files will be imported into R in three steps: first two meta files, secondly the relevant test data files, and lastly the training data files. The files in the `Inertial Signals` folder are skipped as they do not contain the data which are required for the final tidy data set.

#### Step 3.1 - Import Meta Files

Following 'meta' files are loaded into R: 

1. activity_labels.txt
2. features.txt

The first file is stored in `DT_activity`. This information is later needed to map the Activity ID, in both the test and training data set, to the correct Activity Name.

The second file, which is stored in `DT_features`, will later on be used for two purposes:

- Map the variable names (of the imported test and training data set) from V1-V561 into the correct feature name
- Select the correct variables (the `mean()` and `std()` features) for the tidy data set.

#### Step 3.2 - Import Test Data Files

The following files will be imported and merged into one `DT_test`:

1. test/X_test.txt
2. test/y_test.txt
3. test/subject_test.txt

Basically, start with importing the test set (1), the related test activity labels (2) and the corresponding subjects (3). Then merge these three related data into one `DT_test`. Please note that for now only the variables `activity_id` and `subject` have been named accordingly. The rest will be done in step 4.3.

#### Step 3.3 - Import Train Data Files

The same steps as in step 3.2 are performed but now the following files are merged into `DT_train`:

1. train/X_train.txt
2. train/y_train.txt
3. train/subject_train.txt


### Step 4 - Merge and Enhance Test + Training Data

As all relevant files are loaded into R, the data sets `DT_train` and `DT_test` are combined and assigned to `DT_all`. Now, the following data.tables are ready for further processing:

- `DT_all`
- `DT_activity`
- `DT_features`

Based on these objects, the script will then:

1. add the correct activity name to each observation
2. ensure that all subject and activity variables are placed before the feature variables
3. rename the 'unnamed' feature variables (V1 thru V561) to the correct feature variable names


### Step 5 - Create & Export Tidy Data Set

In this last step, the following actions are performed:

1. determine the feature variables which need to be included in the tidy data set
2. create DT_tidy, which matches the project assignment requirement
3. export this data set to a TXT file

#### Step 5.1
Based on requirement #2 of the project assignment ('_Extracts only the measurements on the mean and standard deviation for each measurement_'), a list of features, which either have `mean()` or `std()` in their name, is created based on the list of features in the `DT_features` object. This results in 66 features (of the 561) qualified to this requirement.

***
***

... which can be grouped as follows (according to the `features_info.txt` file):

    3-axial raw signals for:
    - accelerometer (split into two features:
        - tBodyAcc
        - tGravityAcc
    - gyroscope:
        - tBodyGyro

    Jerk signals (derived)
    - tBodyAccJerk
    - tBodyGyroJerk
    
    Magnitude of these three-dimensional signals (calculated)
    - tBodyAccMag
    - tGravityAccMag
    - tBodyAccJerkMag
    - tBodyGyroMag
    - tBodyGyroJerkMag
    
    Fast Fourier Transformations on some of these signals:
    - fBodyAcc
    - fBodyAccJerk
    - fBodyGyro
    - fBodyAccJerkMag
    - fBodyGyroMag
    - fBodyGyroJerkMag


One can discuss

***
***

In the next step, these variables -- along with `activity` and `subject` -- will be used to create the required dataset.


#### Step 5.2
Creating the initial tidy data set, is done by one command:

    DT_tidy <- DT_all[ ,lapply(.SD, mean), by = .(activity, subject), .SDcols = feat_var ]
    
With this one command, basically two requirements are met, i.e.: the subset of feature variables (with the `.SDcols` argument) and the calculated average of each variable for each activity-subject (by means of `lapply(.SD, mean)`). 
To be more specific (see also [data.table cheat sheet](https://www.r-bloggers.com/the-data-table-cheat-sheet/)):

- `lapply(.SD, mean)`
    - calculate the average for each variable for each group as specified in the `by` argument
    - the set of variables to be included is set by the `.SDcols` argument
- `by = .(activity, subject)`
    - group rows by column `activity` + `subject`, on which the average calculation is being performed 
      (group j by column activity and subject, then calculate j)
- `.SDcols = feat_var`
    - by setting this argument only the specified variables will be used for the calculation

The just created `DT_tidy` data set has the following dimensions:

- 180 rows (30 subjects, each having 6 activities) and 
- 68 columns (which are the subject and activity variables and the 66 required feature variables)

#### Step 5.3

This final tidied data set is exported with the `write.table()` function and parameters as specified in the assignment.

___Tip___ _Importing this file can best be done by using the `fread()` function of the `data.table` package. No other parameters than the `input` for the filename is required. By using this function, the variable names are exactly preserved as saved (which is not the case when using `read.table()`)._
