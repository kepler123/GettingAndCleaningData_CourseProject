# This project utilizes various capabilities of R related to working with a "raw" data set, 
# transforming it, and outputting a tidy version of it.
#
# The raw data is the dataset created by the University of Genova, with full description
# available here:
#
#    http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#
# It represents signals data collected from multiple subjects performing various physical activities.
# The data was collected using smartphones.
#
# The actual dataset files are available here:
#
#    https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#
# This R script, per the assignment, does the following:
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set.
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#
# The script outputs this final, tidy data set into a CSV file in the working directory.
# The file's name is tidy_dataset.csv.
#


# Performs the data analysis and transformations and persists the output tidy data set
# into a file named tidy_dataset.csv in the working directory.
run_analysis <- function() {

 cat(">> Running analysis...\n")
 cat(">> Loading input data...\n")    
 dfList <- loadInputData()
 
 cat(">> Processing data...")
 df <- processData(dfList$train, dfList$test)
 
 cat(">> Persisting the output...\n")
 persistOutput(df, "tidy_dataset.csv")
 
 cat(">> Wrote output to tidy_dataset.csv.\n")    
}

# Loads input data into memory for further processing.
#
# Inputs: none
# Outputs: a list of two data frames, the first one being the training set,
# the second one being the test set.
# Note: input files are assumed to be in subdirectories under the current
# working directory (training files under 'train' and test files under 'test'
# subdirectories).
loadInputData <- function() {
    df1 <- loadDataSet("train/subject_train.txt", "train/y_train.txt", "train/X_train.txt")
    df2 <- loadDataSet("test/subject_test.txt", "test/y_test.txt", "test/X_test.txt")
    list("train" = df1, "test" = df2)
}

# Processes the two input datasets:
# 1. Merges the two sets together into one.
# 2. Creates a tidy output data set with the average of each variable for each activity and each subject.
#
# Inputs: the training and test datasets as data frames.
# Outputs: the merged tidied up data frame.
processData <- function(df1, df2) {
    df <- mergeData(df1, df2)
    df <- transformData(df)
}

# Merges two input datasets together into one.
#
# Inputs: the training and test datasets as data frames.
# Outputs: the merged data frame.
mergeData <- function(df1, df2) {
    library(plyr)
    join_all(list(df1, df2))
}

# Transforms the merged data by:
# a) collapsing/flattening it so that a pair of { subject ID, activity ID } is represented by only a single
# row in the output data frame, along with the relevant measurement data for the pair;
# b) calculating averages (means) of the various mean and standard deviation measurement data extracted for
# each pair of subject ID and activity ID;
# c) tidying up the column names for the measurements columns.
#
# Inputs: a data frame with subject ID, activity ID, numeric measurement data in each row.
# Outputs: the "flattened" data frame with { subject ID, activity ID } made unique and followed by the
# respective averages of mean and standard deviation measurement data, one such set of data per row.
transformData <- function(df) {
    df <- ddply(df, c("Subject.ID", "Activity.Type"), numcolwise(mean))
    df <- tidyUpColumns(df)
    df
}

# Labels the data set with descriptive variable names by tidying up the measurement
# variable column names.
#
# Inputs: the data frame.
# Outputs: none.
#
# Note: one might argue whether these are tidy column names or not. A certain amount
# of shortening and use of acronyms (like StdDev instead of "StandardDeviation") is
# done in order to avoid having column names that are too long (which reduces
# the readability of the output data set).
tidyUpColumns <- function(df) {
    names(df) <- gsub("tBody", "Time.Body.", names(df))
    names(df) <- gsub("tGravity", "Time.Gravity.", names(df))
    names(df) <- gsub("fBody", "Frequency.Body.", names(df))
    names(df) <- gsub("Acc", "Accel", names(df))
    
    names(df) <- gsub("-mean\\(\\)-", ".Mean.", names(df))
    names(df) <- gsub("-std\\(\\)-", ".StdDev.", names(df))
    names(df) <- gsub("-mean\\(\\)", ".Mean", names(df))
    names(df) <- gsub("-std\\(\\)", ".StdDev", names(df))
    
    df
}

# Writes the tidy output data set into the output CSV file.
#
# Inputs: the tidy data frame and the name of the file to write to.
# Outputs: none.
persistOutput <- function(df, filename) {
    write.csv(df, filename, row.names=FALSE)
}

# Loads a single subset of data that is a part of the human activity dataset.
#
# Inputs:
# the path to the subject ID data file
# the path to the respective activity ID data file
# the path to the respective numeric measurements data file
#
# Outputs: a data frame which represents all three types of data merged into one data frame.
#
# Notes:
# 1. The input file paths are relative to the current working directory.
# 2. The function assigns descriptive activity names to name the activities in the resulting data frame.
loadDataSet <- function(subjectFile, activityFile, measurementFile) {
    
    # Load the subject data.
    dfRes <- readTableData(subjectFile)
    colnames(dfRes) <- c("Subject.ID")
    
    # Load the activity data.
    dfA <- readTableData(activityFile)
    colnames(dfA) <- c("Activity.Type")
 
    # Merge the subject data and activity data into one data frame, columnwise.
    dfRes$Activity.Type <- dfA$Activity.Type
    
    # Assign descriptive activity names.
    dfRes$Activity.Type[dfRes$Activity.Type == 1] <- "WALKING"
    dfRes$Activity.Type[dfRes$Activity.Type == 2] <- "WALKING_UPSTAIRS"
    dfRes$Activity.Type[dfRes$Activity.Type == 3] <- "WALKING_DOWNSTAIRS"
    dfRes$Activity.Type[dfRes$Activity.Type == 4] <- "SITTING"
    dfRes$Activity.Type[dfRes$Activity.Type == 5] <- "STANDING"
    dfRes$Activity.Type[dfRes$Activity.Type == 6] <- "LAYING"

    # Load the numeric measurements data.
    dfMes <- loadMeasurements(measurementFile)
    
    # Append the measurements data to the subjects+activities, columnwise.
    cbind(dfRes, dfMes)
}

# Loads numeric measurements from a data file. Extracts only the relevant
# data, which is only columns related to averages and standard deviation.
#
# Inputs: the data file.
# Outputs: the measurements data as a data frame.
loadMeasurements <- function(file) {

    # Read in the index of measurement features.
    # The first column is the column index of a feature in the measurements data set.
    # The second column is the respective variable name.
    dff <- readSpaceSeparatedData("features.txt")
    colnames(dff) <- c("index", "var")

    # Read in the space-separated measurements data.
    df <- readSpaceSeparatedData(file)
    
    # Assign columns to the measurements data frame, based on the feature index.
    colnames(df) <- as.vector(dff$var)

    # Identify the columns related to averages and standard deviation.
    dff <- dff[(grepl("^.+(mean\\(\\)|std\\(\\)).*$", dff$var)==TRUE),]

    # Extract and return only data related to averages and standard deviation.
    df[,as.vector(dff$var)]
}


# Reads space-separated data from an input file. Returns it as a data frame.
#
# Inputs: the input file name.
# Outputs: the loaded data, as a data frame.
# See also:
# http://stackoverflow.com/questions/14393192/reading-a-file-in-r-space-separated-skip-first-lines
readSpaceSeparatedData <- function(file) {
    con <- file(file)
    lines <- readLines(con)
    dat <- read.table(text=lines[grep("^[^#]", lines)], stringsAsFactors=FALSE)
    close(con)
    # TODO this must already be a df
    # as.data.frame(dat)
    dat
}

# Reads tabular data from an input file. Returns it as a data frame.
#
# Inputs: the input file
readTableData <- function(file) {
    con <- file(file)
    lines <- readLines(con)
    dat <- read.table(text=lines, stringsAsFactors=FALSE)
    close(con)
    # TODO this must already be a df
    # as.data.frame(dat)
    dat
}



