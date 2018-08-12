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


# Valid EMail Pattern Regular Expression
email_pat = "^([a-z0-9\u0400-\u04FF_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"

#Creating Dirs if already not available
Paths <- list(MainPath, ProcessedPath,OutofScopePath,ResultsPath)
sapply(Paths, function(x) dir.create(x))

files <- list.files(MainPath, pattern = "^Processed-.*txt$", full.names = T,recursive = TRUE)

fileNames <- list.files(MainPath, pattern = "^Processed-.*txt$",recursive = TRUE)

counter <- 1:length(files)

# x<- counter[[1]]

#Exporting variables to all clusters
clusterExport(cl, list("fileNames","files","read_delim","str_split","tbl_df","mutate","setnames","email_pat"))
#Exporting variables to all clusters
clusterEvalQ(cl, {require(stringr);require(data.table);require(dplyr);require(readr)})

#############################################################################################################
filedetails <- parLapply(cl,counter, function(x) {
  
  FileName = fileNames[[x]]
  
  FilePath = files[[x]]
  
  
  dat <- read_delim(FilePath,
                    delim = "\t",
                    col_names = T) %>%
    as.data.table() %>% 
    mutate(PasswordLength = str_length(Password)) %>%
    # # Filtering identical Email and Password with Password length above 5 with invalid email pattern with delimeter as ;
    filter(PasswordLength > 5 & EMail==Password & !is.na(Password) & !grepl(pattern = email_pat,EMail)) 
  
  # Split on Colon   
  dat <- str_split(dat$EMail
                   , pattern = ";"
                   , n = 2)
  
  dat <- as.data.table(do.call(rbind, dat)) %>% setnames(c("EMail","Password")) %>% distinct() 
  
  #Further Splitting the Email with @ separator
  EmailSplitStringR <- str_split(dat$EMail
                                 ,pattern =  "@"
                                 , n = 2)
  #Create Data Table
  EmailSplitStringR <- as.data.table(do.call(rbind, EmailSplitStringR)) %>%
    setnames(c("EMailID","EMailDomain")) 
  
  #binding table
  dat <- bind_cols(dat, EmailSplitStringR)
  
  
})

filedetails_df <- do.call(rbind, filedetails)

write_delim(filedetails_df,path =  paste0(ProcessedPath, "/Processed-SameEmailPassword.txt")  , delim = "\t")

#Clean-up Big Size R-objects and Free up Memory
rm(filedetails,filedetails_df)
gc()

#############################################################################################################
filedetails <- parLapply(cl,counter, function(x) {
  
  FileName = fileNames[[x]]
  
  FilePath = files[[x]]
  
  dat <- read_delim(FilePath,
                    delim = "\t",
                    col_names = T) %>%
    as.data.table() %>% 
    mutate(PasswordLength = str_length(Password)) %>%
    # Filtering identical Email and Password with Password length above 5 and valid email Pattern
    filter(PasswordLength > 5 & EMail==Password & !is.na(Password) & grepl(pattern = email_pat,EMail))
  
})

filedetails_df <- do.call(rbind, filedetails) 

write_delim(filedetails_df,path =  paste0(ProcessedPath, "/Processed-Samemailpasswords-Identical.txt")  , delim = "\t")

#Clean-up Big Size R-objects and Free up Memory
rm(filedetails,filedetails_df)
gc()

#############################################################################################################

filedetails <- parLapply(cl,counter, function(x) {
  
  FileName = fileNames[[x]]
  
  FilePath = files[[x]]
  
  dat <- read_delim(FilePath,
                    delim = "\t",
                    col_names = T) %>%
    as.data.table() %>%
    #Filtering Password as NA values
    filter(is.na(Password))
  
})

filedetails_df <- do.call(rbind, filedetails) 

write_delim(filedetails_df,path =  paste0(OutofScopePath, "/OutofScope-NA-Passwords.txt")  , delim = "\t")

#Clean-up Big Size R-objects and Free up Memory
rm(filedetails,filedetails_df)
gc()

#############################################################################################################
filedetails <- parLapply(cl,counter, function(x) {
  
  FileName = fileNames[[x]]
  
  FilePath = files[[x]]
  
  dat <- read_delim(FilePath,
                    delim = "\t",
                    col_names = T) %>%
    as.data.table()
  
  # Filtering less than 6 char length
  processeddataset <- dat %>%
    mutate(PasswordLength = str_length(Password)) %>%
    filter(PasswordLength < 6)
  
})

filedetails_df <- do.call(rbind, filedetails) 

write_delim(filedetails_df,path =  paste0(OutofScopePath, "/OutofScope-Lessthan6.txt")  , delim = "\t")

#Clean-up Big Size R-objects and Free up Memory
rm(filedetails,filedetails_df)
gc()

#############################################################################################################

filedetails <- parLapply(cl,counter, function(x) {
  
  FileName = fileNames[[x]]
  
  FilePath = files[[x]]
  
  dat <- read_delim(FilePath,
                    delim = "\t",
                    col_names = T) %>%
    as.data.table() %>%
    mutate(PasswordLength = str_length(Password)) %>%
    filter(EMail!=Password & PasswordLength > 5 & !is.na(Password) & grepl(pattern = email_pat,EMail)) 
  
  # Filtered Dataset Summary by domain and Password length
  cleansummarydataset <- dat %>% 
    group_by(EMailDomain,PasswordLength) %>%
    summarise(DistinctEmails=n_distinct(EMail),
              DistinctPasswords=n_distinct(Password)
              ,TotalCount=n())
  
})

#Additional GroupBy for aggregation post rBinding lists
filedetails_df <- do.call(rbind, filedetails) %>%
  group_by(EMailDomain,PasswordLength) %>%
  summarise(DistinctEmails=sum(DistinctEmails),
            DistinctPasswords=sum(DistinctPasswords)
            ,TotalCount=sum(TotalCount))

write_delim(filedetails_df,path =  paste0(ResultsPath, "/Summarybydomain-Combined.txt")  , delim = "\t")

#Clean-up Big Size R-objects and Free up Memory for further processing
rm(filedetails,filedetails_df)
gc()

#############################################################################################################

#stop the cluster to free resources
stopCluster(cl)

