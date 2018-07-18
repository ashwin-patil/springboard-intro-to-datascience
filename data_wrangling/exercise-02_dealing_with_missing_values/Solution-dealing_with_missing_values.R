#Make sure to set the working directory where csv dataset is stored
# Load dataset as dataframe from csv for cleaning
titanic_original <- read.csv("titanic_original.csv")

#Viewing Structure of the dataset
str(titanic_original)

#Viwing dimensions of the dataset
dim(titanic_original)

#print the summary for embarkation to find missing values
summary(titanic_original$embarked)

#Question01 - Port of embarkation : Find the missing values in embarked column and replace them with S
titanic_original$embarked[titanic_original$embarked==""]<- "S"

#print summary again to validate missing values have been replaced with S
summary(titanic_original$embarked)

#Use any function to check if there are any NAs in age column
any(is.na(titanic_original$age))

#Question02 - Age : Find the missing values in Age and replace them with mean of the Age column
titanic_original$age[is.na(titanic_original$age)] <- mean(titanic_original$age,na.rm = TRUE)

#validate if NAs have been replaced
any(is.na(titanic_original$age))

#Print summary to find missing values in boat column
summary(titanic_original$boat)

#To add None to the factor level and refactor the column-titanic_original$boat
#levels(titanic_original$boat)
#levels[length(levels)+1]<-"None"
#titanic_original$boat<-factor(titanic_original$boat,levels=levels)

#Question03 - Lifeboat : Fill the empty slots with dummy value e.g. 'None' or 'NA'
titanic_original$boat[titanic_original$boat==""]<- NA

#titanic_original$boat[is.na(titanic_original$boat)]<- "None"

#load library-dplyr to use mutate function
library(dplyr)

#Question04- Cabin : Create a new column has_cabin_number which has 1 if there is a cabin number, and 0 otherwise.
titanic_clean <- titanic_original %>% 
                    mutate(has_cabin_number=ifelse(cabin=="",0,1))

#writing the output clean file after all transformation
write.csv(titanic_clean,"titanic_clean.csv")
