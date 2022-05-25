#load necessary libraries
library(tidyverse)

#Download the data
if (!(file.exists("DataFiles")))
{ dir.create("DataFiles")}

if (!(file.exists("DataFiles/Dataset.zip")))
{ download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile ="DataFiles/Dataset.zip", method="curl")}

if (!(file.exists("DataFiles/UCI HAR Dataset")))
{unzip("DataFiles/Dataset.zip",exdir="DataFiles")}

#Merge test and train data sets into single data set

#create features vector for column names
features <- read.table("./DataFiles/UCI HAR Dataset/features.txt", quote="\"", comment.char="", check.names = FALSE) %>% pull(V2)

#subset only columns to keep
featurestokeep <- features %>% str_subset("Mean|mean|std")

#Test data parsing
X_test <- read.table("./DataFiles/UCI HAR Dataset/test/X_test.txt", quote="\"", comment.char="", check.names = FALSE, col.names = features)
Y_test <- read.table("./DataFiles/UCI HAR Dataset/test/y_test.txt", col.names = "activity")
subject_test <- read.table("./Datafiles/UCI HAR Dataset/test/subject_test.txt", col.names = "subject")

test <- cbind(subject_test, Y_test, X_test)

rm(subject_test,Y_test, X_test)

#Train data parsing
X_train <- read.table("./DataFiles/UCI HAR Dataset/train/X_train.txt", quote="\"", comment.char="", check.names = FALSE, col.names = features)
Y_train <- read.table("./DataFiles/UCI HAR Dataset/train/y_train.txt", col.names = "activity")
subject_train <- read.table("./Datafiles/UCI HAR Dataset/train/subject_train.txt", col.names = "subject")

train <- cbind(subject_train, Y_train, X_train)

rm(subject_train, Y_train, X_train)

#combine train and test data sets
finaldata <- rbind(train, test)
rm(train, test)

#Subset data set to only mean and std columns
finaldata <- finaldata %>% select(subject, activity, featurestokeep)

#convert activity column to factors and label each activity
labels <- read.delim("./DataFiles/UCI HAR Dataset/activity_labels.txt", header = FALSE, sep = " " )

names(labels) <- c("activity_id", "activity_name")

finaldata$activity <- factor(finaldata$activity,
                    levels = labels$activity_id,
                    labels = labels$activity_name)

#create new data set of mean for each activity and subject
summarydata <- finaldata %>% group_by(activity, subject) %>% summarize_all(mean)
rm(labels)

write.table(summarydata, file = "summarydata.txt", row.names = FALSE)
