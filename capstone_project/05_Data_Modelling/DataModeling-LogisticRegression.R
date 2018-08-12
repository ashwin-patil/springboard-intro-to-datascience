# Load Packages
pkgs <- c(pkgs <- c("parallel","readr","stringr","data.table", "dplyr"))
sapply(pkgs, function(x) suppressPackageStartupMessages(require(x, character.only = T)))


# Calculate the number of cores
no_cores <- detectCores() - 2

# Initiate cluster
cl <- makeCluster(no_cores)

#Suppress warnings
options(warn=-1)
suppressWarnings('read_delim')

# Set Paths
MainPath <- "C:/Users/ashwin/Downloads/BreachCompilation/data/"
ProcessedPath <- "C:/Users/ashwin/Downloads/BreachCompilation/data/Processed"
OutofScopePath <- "C:/Users/ashwin/Downloads/BreachCompilation/OutOfScope"
ResultsPath <- "C:/Users/ashwin/Downloads/BreachCompilation/Results/"
ResultsPathSummary <- "C:/Users/ashwin/Downloads/BreachCompilation/Results/Summary"


#Creating Dirs if already not available
Paths <- list(MainPath, ProcessedPath,OutofScopePath,ResultsPath,ResultsPathSummary)
sapply(Paths, function(x) dir.create(x))

files <- list.files(MainPath, pattern = "^Processed-.*txt$", full.names = T,recursive = TRUE)

fileNames <- list.files(MainPath, pattern = "^Processed-.*txt$",recursive = TRUE)

counter <- 1:length(files)

# x<- 1

email_pat = "^([a-z0-9\u0400-\u04FF_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"

# x<- counter[[1]]

#Exporting variables to all clusters
clusterExport(cl, list("fileNames","files","read_delim","str_split","tbl_df","mutate","setnames","table","email_pat"))
#Exporting variables to all clusters
clusterEvalQ(cl, {require(stringr);require(data.table);require(dplyr);require(readr)})

#############################################################################################################

# #############################################################################################################
#
#
filedetails <- parLapply(cl,counter, function(x) {

  FileName = fileNames[[x]]

  FilePath = files[[x]]

  dat <- read_delim(FilePath,
                    delim = "\t",
                    col_names = T) %>%
    as.data.table() %>%
    mutate(PasswordLength = str_length(Password)) %>%
    filter(PasswordLength > 5 & !is.na(Password) & grepl(pattern = email_pat,EMail)) %>%
    filter(EMailDomain == "gmail.ru" | EMailDomain ==  "gmail.co.uk")




  dat <- dat %>% mutate(lower.alpha.count = str_count(Password, pattern = "[a-z]"),
                                        upper.alpha.count = str_count(Password, pattern = "[A-Z]"),
                                        numeric.count = str_count(Password, pattern = "[0-9]"),
                                        alphanumeric.count = str_count(Password, pattern = "[:alnum:]"),
                                        punct.count = str_count(Password, pattern = "[:punct:]"),
                                        cyrillic.count = str_count(Password, pattern = "[\u0400-\u04FF]"),
                                        total.count = str_count(Password, pattern = "[:graph:]")
                                        , EMailDomain=  as.factor(EMailDomain))


})

fildetails_df <- do.call(rbind, filedetails)

#Writing Clean files into Results Dir
write_delim(fildetails_df,path = paste0(ResultsPath, "/Results-forRegression-", basename(FilePath))  , delim = "\t")

#############################################################################################################

# Splitting the dataset into Respective EMailDomain -----------------------

datSplit <-  split(fildetails_df, fildetails_df$EMailDomain)


sampSize <- min(nrow(datSplit$gmail.co.uk), nrow(datSplit$gmail.ru))


datSplit[[1]] <- datSplit[[1]] %>% sample_n(sampSize)
datSplit[[2]] <- datSplit[[2]] %>% sample_n(sampSize)

datspli_sample<- bind_rows(datSplit) 


###############################
set.seed(8675309)

datspli_sample <- datspli_sample %>%
  mutate(TestTrain =  sample(c(0,1), size = nrow(datspli_sample), prob = c(.75, .25), replace = T)
         , EMailDomain = as.factor(EMailDomain))

df_train <- datspli_sample %>% filter(TestTrain==0)
df_test <- datspli_sample %>% filter(TestTrain==1) %>% mutate(EmailTrue = ifelse(EMailDomain == "gmail.co.uk", 1, 0))


# Compiling logistic formula for the glm function -------------------------

RegFormula <- as.formula("EMailDomain ~ lower.alpha.count + upper.alpha.count + numeric.count + punct.count + cyrillic.count + total.count")

LM1 <- glm(RegFormula,df_train ,family = "binomial")

lmSummary <- summary(LM1)


df_test$Predicted <- predict.glm(LM1, df_test,type = "response")

#Confusion metrix
table(df_test$EMailDomain, df_test$Predicted>0.5)


Threshold <- 0.4

df_test <- df_test %>% 
  mutate(Preds = ifelse(Predicted > Threshold, 0, 1)) %>% mutate(EmailTrue=as.factor(EmailTrue), Preds=as.factor(Preds))


# Generating Confusion Matrix ---------------------------------------------
library(caret)
confusionMatrix(df_test$EmailTrue, df_test$Preds)

#ROC Curve
library(ROCR)
ROCRpredict <- prediction(df_test$Predicted, df_test$EMailDomain)

ROCRperf <- performance(ROCRpredict, 'tpr', 'fpr')

plot(ROCRperf, colorize=TRUE, text.adj = c(-0.2,1.7))


gmailuk = df_test %>% filter(EMailDomain=="gmail.co.uk")

gmailru= df_test %>% filter(EMailDomain=="gmail.ru")



# Generating AUC values for Model Performance -----------------------------


auc <- performance(ROCRpredict, measure = "auc")
auc <- auc@y.values[[1]]
auc

auc(df_test$EMailDomain,df_test$Predicted)



# New Stas without Statistically insignificant variables ------------------



newRegFormula <- as.formula("EMailDomain ~ lower.alpha.count + upper.alpha.count + numeric.count + total.count")

newLM1 <- glm(newRegFormula,df_train ,family = "binomial")

newlmSummary <- summary(newLM1)

newlmSummary

df_test$Predicted <- predict.glm(newLM1, df_test,type = "response")

#Confusion metrix
table(df_test$EMailDomain, df_test$Predicted>0.5)


Threshold <- 0.4

df_test <- df_test %>% 
  mutate(Preds = ifelse(Predicted > Threshold, 0, 1)) %>% mutate(EmailTrue=as.factor(EmailTrue), Preds=as.factor(Preds))

library(caret)
confusionMatrix(df_test$EmailTrue, df_test$Preds)

#ROC Curve
library(ROCR)
ROCRpredict <- prediction(df_test$Predicted, df_test$EMailDomain)

ROCRperf <- performance(ROCRpredict, 'tpr', 'fpr')

plot(ROCRperf, colorize=TRUE, text.adj = c(-0.2,1.7))


gmailuk = df_test %>% filter(EMailDomain=="gmail.co.uk")

gmailru= df_test %>% filter(EMailDomain=="gmail.ru")

auc <- performance(ROCRpredict, measure = "auc")
auc <- auc@y.values[[1]]
auc

