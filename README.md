This project utilizes various capabilities of R related to working with a "raw" data set, transforming it, and outputting a tidy version of it.

The raw data is the dataset created by the University of Genova, with full description
available here:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

It represents signals data collected from multiple subjects performing various physical activities. The data was collected using smartphones.

The actual dataset files are available here:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The run_analysis.R script, per the assignment, does the following:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set.
4. Appropriately labels the data set with descriptive variable names. 
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

The script outputs this final, tidy data set into a CSV file in the working directory. The file's name is tidy_dataset.csv.

<hr/>

Internally, the script works as follows:

1. Load the two subsets of data into memory, each as a data frame:
  1. Load the "train/subject_train.txt", "train/y_train.txt", "train/X_train.txt" files, merge them into one data frame.
  2. Load the "test/subject_test.txt", "test/y_test.txt", "test/X_test.txt", merge them into one data frame.
  3. For each of these data frames, the resulting data frame consists of: the subject ID column, the activity ID column, then the numeric measurement columns.
  4. In both cases, the activity values are remapped from integer constants to "telling" string values such as "WALKING", "STANDING", etc., to make the data tidier and more readable.
  5. The measurement data loading is performed as follows:
    1. Space-separated numeric measurements data is read from the X_... file, as a data frame.
    2. The features index is loaded from the features.txt file, as a data frame where the first column represents the index values for measurements columns; the second column contains the respective feature (variable) name such as e.g. "tBodyAcc-mean()-X".
    3. The variable names are assigned to the respective columns of the measurements data frame, based on the features index.
    4. The measurements data frame is sliced to only contain columns related to mean or standard deviation measurements. This is done based on the column (variable) name, where columns related to means are named "...-mean()-..." or "...-mean()"; columns related to standard deviation are named "...-std()-..." or "...-std()".
2. The data is then further processed:
  1. The two data frames representing training and test data are merged into one data frame.
  2. The merged data frame is further transformed by:
    1. Collapsing/flattening it so that a pair of { subject ID, activity ID } is represented by only a single row in the output data frame, along with the relevant measurement data for the pair.
    2. Calculating averages (means) of the various mean and standard deviation measurement data extracted for each pair of subject ID and activity ID.
    3. Tidying up the column names for the measurements columns, with the chosen convention to:
      1. clearly identify the "domain" of the measurement, as "Time" vs. "Frequency" e.g. Time.Body.Accel.Mean.X, Frequency.Body.Accel.Mean.X.
      2. more clearly identify the data sources as accelerometer vs. gyroscope as "Accel", "Gyro";
      3. identify the mean/average measurements as "Mean";
      4. identify the standard deviation measurements as "StdDev", which is a standard acronym for standard deviation;
      5. some tradeoffs between pure tidyness vs. readability of the output were made, as far as these columns names: the names are not 100% spelled out but contain just enough hints to allow reader to understand data clearer, without making the column names too long.
3. The tidied up data set is consequently persisted into the working directory, as a CSV file named "tidy_dataset.csv".

