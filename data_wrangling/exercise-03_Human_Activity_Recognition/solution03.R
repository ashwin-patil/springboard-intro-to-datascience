#load the libraries
library(dplyr)
library(tidyr)

#Make sure to set the working directory where csv dataset is stored
# Load all text files from test dataset into individual dataframes
subject_test <- read.table("test/subject_test.txt")
x_test <- read.table("test/X_test.txt")
y_test <- read.table("test/Y_test.txt")
body_acc_x_test <- read.table("test/Inertial Signals/body_acc_x_test.txt")
body_acc_y_test <- read.table("test/Inertial Signals/body_acc_y_test.txt")
body_acc_z_test <- read.table("test/Inertial Signals/body_acc_z_test.txt")
body_gyro_x_test <- read.table("test/Inertial Signals/body_gyro_x_test.txt")
body_gyro_y_test <- read.table("test/Inertial Signals/body_gyro_y_test.txt")
body_gyro_z_test <- read.table("test/Inertial Signals/body_gyro_z_test.txt")
total_acc_x_test <- read.table("test/Inertial Signals/total_acc_x_test.txt")
total_acc_y_test <- read.table("test/Inertial Signals/total_acc_y_test.txt")
total_acc_z_test <- read.table("test/Inertial Signals/total_acc_z_test.txt")

# Load all text files from training dataset into individual dataframes
subject_train <- read.table("train/subject_train.txt")
x_train <- read.table("train/X_train.txt")
y_train <- read.table("train/Y_train.txt")
body_acc_x_train <- read.table("train/Inertial Signals/body_acc_x_train.txt")
body_acc_y_train <- read.table("train/Inertial Signals/body_acc_y_train.txt")
body_acc_z_train <- read.table("train/Inertial Signals/body_acc_z_train.txt")
body_gyro_x_train <- read.table("train/Inertial Signals/body_gyro_x_train.txt")
body_gyro_y_train <- read.table("train/Inertial Signals/body_gyro_y_train.txt")
body_gyro_z_train <- read.table("train/Inertial Signals/body_gyro_z_train.txt")
total_acc_x_train <- read.table("train/Inertial Signals/total_acc_x_train.txt")
total_acc_y_train <- read.table("train/Inertial Signals/total_acc_y_train.txt")
total_acc_z_train <- read.table("train/Inertial Signals/total_acc_z_train.txt")

#activity label and feature
activity_labels <- read.table("activity_labels.txt")
features <- read.table("features.txt")


#Merge the training and test data sets to create one data set
subject_combined <- rbind(subject_test,subject_train)
names(subject_combined)<- c('subject')

X_combined <- rbind(x_test,x_train)
names(X_combined) <- make.names(features$V2,unique = TRUE)

Y_combined <- rbind(y_test,y_train)
names(Y_combined) <- c('ActivityLabel')

#Question 03-Add new variables : 
#Create variables called ActivityLabel and ActivityName that label all observations with the corresponding activity labels and names respectively
names(activity_labels) <- c('ActivityLabel', 'ActivityName')

#Question01-Merge the datasets
final_data <- cbind(subject_combined, Y_combined) %>% 
              left_join(activity_labels) %>% 
              cbind(X_combined)

#Question02-Mean and standard deviation
#Create two new columns, containing the mean and standard deviation for each measurement respectively. 
#Hint: Since some feature/column names are repeated, you may need to use the make.names() function in R.
new_data <- select(final_data,contains("mean"),contains("std"))

# Question 04 - Create tidy data set
#From the data set in step 3, creates a second, independent tidy data set with the average of each variable for each activity and each subject
tidy_data <- new_data %>% 
