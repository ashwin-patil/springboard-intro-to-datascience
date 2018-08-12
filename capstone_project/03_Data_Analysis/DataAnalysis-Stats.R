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

files <- list.files(MainPath, pattern = "^Summary-byEmailDomain-.*txt$", full.names = T,recursive = TRUE)

fileNames <- list.files(MainPath, pattern = "^Summary-byEmailDomain-.*txt$",recursive = TRUE)


counter <- 1:length(files)

email_pat = "^([a-z0-9\u0400-\u04FF_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"

#Exporting variables to all clusters
clusterExport(cl, list("fileNames","files","read_delim","str_split","tbl_df","mutate","setnames","table","email_pat"))
#Exporting variables to all clusters
clusterEvalQ(cl, {require(stringr);require(data.table);require(dplyr);require(readr)})


# Summary file generation by PasswordLength -------------------------------


filedetails <- parLapply(cl,counter, function(x) {
  
  FileName = fileNames[[x]]
  
  FilePath = files[[x]]
  
  dat <- read_delim(FilePath,
                    delim = "\t",
                    col_names = T) %>%
    as.data.table() %>% 
    filter(PasswordLength > 5) %>% 
    group_by(PasswordLength) %>% 
    summarise(DistinctPasswords=n_distinct(Password),
              DistinctEmailDomain=sum(DistinctEmailDomain),
              DistinctEmails=sum(DistinctEmails), 
              TotalCount=sum(TotalCount))
  
})

filedetails_df <- do.call(rbind, filedetails)%>% 
  group_by(PasswordLength) %>% 
  summarise(DistinctPasswords=sum(DistinctPasswords),
            DistinctEmailDomain=sum(DistinctEmailDomain),
            DistinctEmails=sum(DistinctEmails), 
            TotalCount=sum(TotalCount))

write_delim(filedetails_df,path =  paste0(ResultsPath, "/Summary-PasswordLength.txt")  , delim = "\t")

#Clean-up Big Size R-objects and Free up Memory for further processing
rm(filedetails)
gc()


# Summary File generation by EmailDomain ----------------------------------
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
    filter(PasswordLength > 5 & !is.na(Password) & grepl(pattern = email_pat,EMail))
  
  # Filtered Dataset Summary by domain and Password length
  cleansummarydataset <- dat %>%
    group_by(EMailDomain,Password,PasswordLength) %>%
    summarise(DistinctEmails=n_distinct(EMail),
              DistinctPasswords=n_distinct(Password)
              ,TotalCount=n())
  
  #Stripping the BasePath to Append Cleandataset dir under it to store results
  BasePath<- dirname(FilePath)
  
  #Writing Clean files into Results Dir
  write_delim(cleansummarydataset,path = paste0(BasePath, "/Summary-byEmailDomain-", basename(FilePath))  , delim = "\t")
  
})


#Clean-up Big Size R-objects and Free up Memory for further processing
rm(filedetails)
gc()
