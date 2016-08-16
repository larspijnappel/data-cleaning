# README data-cleaning

The results of this Peer Graded Assignment for the __Getting and Cleaning Data Course__ contains the following output:

    - README.MD (this file)
    - Tidy Data Set
    - Codebook
    - run_analysis.R
    

> Tidy Data Set

The tidied dataset (`tdf_tidy-step5.txt`) can be found on the Coursera site https://www.coursera.org/learn/data-cleaning/peer/FIZtT/getting-and-cleaning-data-course-project/submit

Importing this output file can be done by using the `read.table()` function with parameters `header=T` and `stringsAsFactors=F`.


> Codebook

For the tidied data set, the corresponding codebook `code_book.txt` describes details regarding the structure of this data set. This codebook can be found in this Github repo.

## run_analysis.R explained

This script contains the following steps to execute the assignment and produce the output dataset `tdf_tidy-step5.txt`. Each of these steps are reflected in the `run_analysis.R script` and is further explained hereafter.

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

During initialisation all objects are removed and the packages `data.table`, `dplyr` and `tidyr` will be loaded. When needed, a new project directory `PGA_lp` is created in which the input and output files are stored.

### Step 2 - Get Source Data

The source data will be downloaded and extracted from the (as specified) url https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

### Step 3 - Import Source Files

Before starting to import all relevant files, the import directory is determined. Then the downloaded source files will be imported into R in three steps:

#### Step 3.1 - Import Meta Files

Import following files:

1. activity_labels.txt
2. features.txt

The first file (which contains the mapping of activity ID and activity description) will be stored in `DT_activity` and later used to relabel the Activity ID in the data sets into the more meaningful Activity Name.

The second file  will be stored in `DT_features` and will be used later for two purposes:

- Map the variable names (of the imported test and training data set) from V1-V561 into the correct feature name
- Select the correct variables (the `mean()` and `std()` features) for the tidy data set.

#### Step 3.2 - Import Test Data Files

The following files will be imported and merged into one `DT_test`:

1. test/X_test.txt
2. test/y_test.txt
3. test/subject_test.txt

Basically, start with importing the test set (1), the related test activity labels (2) and the corresponding subjects (3). Then merge these three related data into one `DT_test` where the order of variables are as follows:

- subject
- activity_id
- V1 thru V561 (these will be renamed in step 4)

#### Step 3.3 - Import Train Data Files

The same steps as in step 3.2 are performed but now the following files are merged into `DT_train`:

1. train/X_train.txt
2. train/y_train.txt
3. train/subject_train.txt

### Step 4 - Merge and Enhance Test + Training Data

Append the training set `DT_train` to the test set `DT_test` and assign it to `DT_all`. Now, the following objects are ready for further processing:

- `DT_all`
- `DT_activity`
- `DT_features`

This script will then:

1. add the correct activity name to each observation and remove the (now obsolete) activity_id variable
2. ensure that all subject and activity related variables are placed before the feature variables
3. rename these feature variable names (V1 thru V561) by mapping them onto the feature list

### Step 5 - Create & Export Tidy Data Set

In this last step, the following actions are performed:

1. determine feature variables to be included in the tidy data set (see requirement #2 of the project assignment)
2. create DT_tidy, which matches the project assignment requirement #2 and # 5
3. tidy this dataset into a 'long form'
4. export to TXT file

#### Step 5.1
Based on requirement #2 of the project assignment ('_Extracts only the measurements on the mean and standard deviation for each measurement_'), a list of features, which either have `mean()` or `std()` in their name, is created based on the `DT_features` object. These variables will be included in the `DT_tidy` object, which will be created in the next step.

#### Step 5.2
Creating the initial tidy data set, is done by one command:

    DT_tidy <- DT_all[ ,lapply(.SD, mean), by = .(activity, subject), .SDcols = feat_var ]
    
With this one command, basically two requirements -- regarding the subset of feature variables (with the `.SDcols` argument) and the average of each variable for each activity and each subject (with the `lapply(.SD, mean)` argument) -- are met. 
To be more specific (see also [data.table cheat sheet](https://www.r-bloggers.com/the-data-table-cheat-sheet/)):

- `lapply(.SD, mean)`
    - .SD is a data.table and holds all the values of all columns, except the one specified in by.
    - calculate the mean for each column (except the one specified in `by`)
- `by = .(activity, subject)`
    - group j by column activity and subject, then calculate j
- `.SDcols = feat_var`
    - .SDcols is used together with .SD, to specify a subset of the columns of .SD to be used in j.

#### Step 5.3

The just created `DT_tidy` data set has the following dimensions:

- 180 rows (30 subjects, each having 6 activities) and 
- 68 columns (of which one subject, one activity name and the remaining 66 matching the feature requirements)

As the 66 features appear to me not as real variables -- but rather as a value of the more generic variable `feature` -- I've chosen to reshape this data set by means of the `tidyr` function `gather()` and assign the end result to `tdf_tidy`. Note that using this function the class is changed from `data.table` to `data.frame` (which I don't like) to `tbl_df` (a tabled dataframe).

The dimension of this final data set is:

- 11880 rows (66 features have now been gathered for each of the 180 subject-activity combination)
- 4 columns (containing the activity, subject, feature name and feature average)

#### Step 5.4

This final tidied data set is exported with the required `write.table()` function and parameters.
