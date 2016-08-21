# README PGA data-cleaning

The results of this Peer Graded Assignment for the __Getting and Cleaning Data Course__ contains the following output:

    - README.MD (this file)
    - Tidy Data Set
    - Codebook
    - run_analysis.R
    
## Tidy Data Set

The tidied dataset (`DT_tidy_A.txt`) can be found on the Coursera site https://www.coursera.org/learn/data-cleaning/peer/FIZtT/getting-and-cleaning-data-course-project/submit

___Tip___ _Importing this file can best be done by using the `fread()` function of the `data.table` package. No other parameters than the `input` for the filename is required._

## Codebook

For the tidied data set, the corresponding codebook `code_book.md` describes details regarding the structure of this data set. This codebook can be found in this Github repo.

## run_analysis.R explained

This script contains the following steps to execute the assignment and produce the output dataset `DT_tidy_A.txt`. Each of these steps are also explained within the `run_analysis.R` script.

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

___Tip___ _Very useful resources for these packages are the [data.table cheat sheet](https://www.r-bloggers.com/the-data-table-cheat-sheet/) and [dplyr & tidyr data wrangling cheat sheet](https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf)_

### Step 2 - Get Source Data

The source data will be downloaded and extracted from the (as specified) url https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip


### Step 3 - Import Source Files

Before starting to load all needed files, the import directory is determined. The source files will be imported into R in three steps: first two meta files, secondly the relevant test data files, and lastly the training data files. The files in the `Inertial Signals` folder are skipped as they do not contain the data which are required for the final tidy data set.

#### Step 3.1 - Import Meta Files

Following 'meta' files are loaded into R: 

1. activity_labels.txt
2. features.txt

The first file is stored in `DT_activity`. This information is later needed to map the activity id, in both the test and training data set, to the correct activity name.

The second file, which is stored in `DT_features`, will later on be used for two purposes:

- Map the variable names (of the imported test and training data set) from V1-V561 into the correct feature name
- Select the correct variables, the `mean()` and `std()` features, for the tidy data set.

#### Step 3.2 - Import Test Data Files

The following files will be imported and merged into one `DT_test`:

1. test/X_test.txt
2. test/y_test.txt
3. test/subject_test.txt

Basically, start with importing the test set (1), the related test activity id's (2) and the corresponding subjects (3). Then merge these three related data files into one `DT_test`. Please note that for now only the variables `activity_id` and `subject` have been named accordingly. The rest will be done in step 4.3.

#### Step 3.3 - Import Train Data Files

The same steps as in 3.2 are performed but now the following files are merged into `DT_train`:

1. train/X_train.txt
2. train/y_train.txt
3. train/subject_train.txt


### Step 4 - Merge and Enhance Test + Training Data

As all relevant files are loaded into R, the data sets `DT_test` and `DT_train` will be combined into `DT_all` after which the following data.tables are ready for further processing:

- `DT_all`
- `DT_activity`
- `DT_features`

Based on these objects, the script will then:

1. add the correct activity name to each observation
2. ensure that all subject and activity variables are placed before the feature variables
3. rename the 'unnamed' feature variables (V1 thru V561) to the correct feature variable names

The merged `DT_all` data set has 564 columns and 10299 rows. The number of rows is explained by the fact that for each of the 30 subjects numerous observations have been performed for each of the 6 activities (see table below). In the next step, these observations will be collapsed into one averaged observation for each activity-subject combination.

    > with( DT_all, table( activity, subject ) )
    
                        subject
    activity            1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
    LAYING             50 48 62 54 52 57 52 54 50 58 57 60 62 51 72 70 71 65 83 68 90 72 72 72 73 76 74 80 69 70
    SITTING            47 46 52 50 44 55 48 46 50 54 53 51 49 54 59 69 64 57 73 66 85 62 68 68 65 78 70 72 60 62
    STANDING           53 54 61 56 56 57 53 54 45 44 47 61 57 60 53 78 78 73 73 73 89 63 68 69 74 74 80 79 65 59
    WALKING            95 59 58 60 56 57 57 48 52 53 59 50 57 59 54 51 61 56 52 51 52 46 59 58 74 59 57 54 53 65
    WALKING_DOWNSTAIRS 49 47 49 45 47 48 47 38 42 38 46 46 47 45 42 47 46 55 39 45 45 36 54 55 58 50 44 46 48 62
    WALKING_UPSTAIRS   53 48 59 52 47 51 51 41 49 47 54 52 55 54 48 51 48 58 40 51 47 42 51 59 65 55 51 51 49 65



### Step 5 - Create & Export Tidy Data Set

In this last step, the following actions are performed:

1. determine the feature variables which need to be included in the tidy data set
2. create DT_tidy, which matches the project assignment requirements
3. export this data set to a TXT file

_Note_

_Organizing the tidy data set was quite challenging as the assignment requirements are far from very specific. This was recognized by many other students and my considerations were between option A and C (as laid out by the topic starter Kai-Ting Neo - see discussion [Clarification on definition of a variable for Step 5 of the assignment](https://www.coursera.org/learn/data-cleaning/discussions/all/threads/-Cjtsip5Eea0DRLrrvCCTQ)). I've decided to go for option A, although it would be very easy to go from option A to option C with the following command (see `run_analysis.R` for exact details):_
    
    > DT_tidy_C <- data.table( gather( DT_tidy_A, 'feat_name', 'feat_value', 3:68 ) )

#### Step 5.1
Based on requirement #2 of the project assignment (_"Extracts only the measurements on the mean and standard deviation for each measurement"_), a list of features -- which either have `mean()` or `std()` in their name -- is created, based on the list of features in the `DT_features` object. This results in 66 features qualified to this requirement.

In the next step, these variables -- along with `activity` and `subject` -- will be used to create the required dataset.

#### Step 5.2
Not only requirement #2, but also #5 (_"[..] the average of each variable for each activity and each subject."_) is realised in this step. Creating this tidy data set is done as follows:

    > DT_tidy_A <- DT_all[ ,lapply(.SD, mean), by = .(activity, subject), .SDcols = feat_var ]
    
With this one command, basically two requirements are met, i.e.: #2 the subset of feature variables (with the `.SDcols` argument) and #5 the calculated averages (by means of `lapply(.SD, mean)`). To be more specific:

- `lapply(.SD, mean)`
    - calculate the average for each variable for each group as specified in the `by` argument
    - the set of variables to be included is determined by the `.SDcols` argument
- `by = .(activity, subject)`
    - group rows by column `activity` + `subject`, on which the average calculation is being performed 
      (group j by column activity and subject, then calculate j)
- `.SDcols = feat_var`
    - by setting this argument only the specified variables will be used for the calculation

The just created `DT_tidy_A` data set has the following dimensions:

- 180 rows (30 subjects, each having 6 activities) 
- 68 columns (which are the variables subject, activity and the 66 required feature variables)

#### Step 5.3

This final tidied data set is exported with the `write.table()` function and parameters as specified in the assignment.

___Tip___ _Importing this file can best be done by using the `fread()` function of the `data.table` package. No other parameters than the `input` for the filename is required. By using this function, the variable names are exactly preserved as saved (which is not the case when using `read.table()`)._
