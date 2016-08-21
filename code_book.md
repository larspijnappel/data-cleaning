
### Code Book PGA data-cleaning

This code book provides details regarding the structure and details of the final tidied data set `DT_tidy_A.txt` (see the README.md file for more context and background information). 

### Observations explained
The merged data set (from the source files) has 10299 rows. The number of rows is explained by the fact that for each of the 30 subjects numerous observations have been performed for each of the 6 activities. This tidied data set contains for each combination of activity and subject the averaged measurement per feature (resulting in __180 observations__). 

### Variables explained

From the 561 features in the source data, only 66 (containing measurements on the mean and standard deviation) have been included in this dataset. Besides these features, this dataset contain two additional variables (i.e. activity and subject) which brings the total to __68 variables__.

The first two variables are:  

- activity
    - This variable lists the six different activities which have been carried out during the experiment: WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING.
.
- subject
    - A total of 30 subjects have participated in the experiment. 

_sidenote: The split of all experiment observations into the test and training data sets have been done by subject (which can easily be verified with the commands `table(DT_test$subject)` and `table(DT_train$subject)`_.

#### Features explained
The remaining 66 variables ar features which can be grouped as follows:

    3-axial raw signals for:
    - accelerometer, split further into:
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
    - fBodyAccMag
    - fBodyGyroMag
    - fBodyAccJerkMag
    - fBodyGyroJerkMag


The naming conventions are as follows:

- `t`               : time domain signals (captured at a constant rate of 50 Hz)
- `f`               : frequency domain signals
- `BodyAcc`         : body acceleration signals
- `GravityAcc`      : gravity acceleration signals
- `BodyGyro`        : body gyroscope signals
- `-X`, `-Y`, `-Z`  : 3-axial signals
- `mean()`          : Mean value
- `std()`           : Standard deviation

#### Raw signals for accelerometer and gyroscope
The features selected for this tidied dataset come from the accelerometer (denoted `Acc`) and gyroscope (denoted `Gyro`) 3-axial raw signals. These time domain signals (prefix `t` to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise.

3-axial raw signals for accelerometer, split by body (__BodyAcc__) and gravity (__GravityAcc__):

- tBodyAcc-mean()-X
- tBodyAcc-mean()-Y
- tBodyAcc-mean()-Z
- tBodyAcc-std()-X
- tBodyAcc-std()-Y
- tBodyAcc-std()-Z

- tGravityAcc-mean()-X
- tGravityAcc-mean()-Y
- tGravityAcc-mean()-Z
- tGravityAcc-std()-X
- tGravityAcc-std()-Y
- tGravityAcc-std()-Z

3-axial raw signals for gyroscope (__BodyGyro__):

- tBodyGyro-mean()-X
- tBodyGyro-mean()-Y
- tBodyGyro-mean()-Z
- tBodyGyro-std()-X
- tBodyGyro-std()-Y
- tBodyGyro-std()-Z

#### Jerk signals
The body linear acceleration (__BodyAccJerk__) and angular velocity (__BodyGyroJerk__) were derived in time to obtain Jerk signals:

- tBodyAccJerk-mean()-X
- tBodyAccJerk-mean()-Y
- tBodyAccJerk-mean()-Z
- tBodyAccJerk-std()-X
- tBodyAccJerk-std()-Y
- tBodyAccJerk-std()-Z

- tBodyGyroJerk-mean()-X
- tBodyGyroJerk-mean()-Y
- tBodyGyroJerk-mean()-Z
- tBodyGyroJerk-std()-X
- tBodyGyroJerk-std()-Y
- tBodyGyroJerk-std()-Z

The magnitude (__Mag__) of these three-dimensional signals were calculated using the Euclidean norm: 

- tBodyAccMag-mean()
- tBodyAccMag-std()

- tGravityAccMag-mean()
- tGravityAccMag-std()

- tBodyAccJerkMag-mean()
- tBodyAccJerkMag-std()

- tBodyGyroMag-mean()
- tBodyGyroMag-std()

- tBodyGyroJerkMag-mean()
- tBodyGyroJerkMag-std()

#### Fast Fourier Transform (FFT)
a Fast Fourier Transform (`f` denotes the frequency domain signals) was applied to some of these signals producing:

__fBodyAcc__

- fBodyAcc-mean()-X
- fBodyAcc-mean()-Y
- fBodyAcc-mean()-Z
- fBodyAcc-std()-X
- fBodyAcc-std()-Y
- fBodyAcc-std()-Z

__fBodyAccJerk__

- fBodyAccJerk-mean()-X
- fBodyAccJerk-mean()-Y
- fBodyAccJerk-mean()-Z
- fBodyAccJerk-std()-X
- fBodyAccJerk-std()-Y
- fBodyAccJerk-std()-Z

__fBodyGyro__

- fBodyGyro-mean()-X
- fBodyGyro-mean()-Y
- fBodyGyro-mean()-Z
- fBodyGyro-std()-X
- fBodyGyro-std()-Y
- fBodyGyro-std()-Z

__fBodyAccMag__

- fBodyAccMag-mean()
- fBodyAccMag-std()

__fBodyGyroMag__

- fBodyBodyGyroMag-mean()
- fBodyBodyGyroMag-std()

__fBodyAccJerkMag__

- fBodyBodyAccJerkMag-mean()
- fBodyBodyAccJerkMag-std()

__fBodyGyroJerkMag__

- fBodyBodyGyroJerkMag-mean()
- fBodyBodyGyroJerkMag-std()

