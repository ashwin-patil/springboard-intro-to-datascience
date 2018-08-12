# Load Packages
pkgs <- c(pkgs <- c("parallel","readr","stringr","data.table", "dplyr"))
sapply(pkgs, function(x) suppressPackageStartupMessages(require(x, character.only = T)))


# Calculate the number of cores
no_cores <- detectCores() - 1

# Initiate cluster
cl <- makeCluster(no_cores)

#Suppress warnings
options(warn=-1)
suppressWarnings('read_delim')


# Set Working Directory ---------------------------------------------------
setwd("C:/Users/ashwin/Downloads/OriginalDataset/BreachCompilation")


# Set Paths
MainPath <- "data/"
ResultsPath <- "Results/"

Paths <- list(MainPath, ResultsPath)
sapply(Paths, function(x) dir.create(x))

files <- list.files(MainPath, pattern = ".txt", full.names = T,recursive = TRUE)

fileNames <- list.files(MainPath, pattern = ".txt",recursive = TRUE)

counter <- 1:length(files)

x<- counter[[1]]

#Exporting variables to all clusters
clusterExport(cl, list("fileNames","files","read_delim"))



# Reading and generating FileStas for all files in the dataset ------------

filestats <- parLapply(cl,counter, function(x) {
  
  
  FileName = fileNames[[x]]
  
  FilePath = files[[x]]
  
  xx <- read_delim(FilePath,
                   delim = "\t",
                   escape_double = FALSE,
                   col_names = FALSE,
                   trim_ws = T)
  
  
  data.frame(
    FileName = FileName
    
    , FilePath = FilePath
    
    , RowCount = nrow(xx)
    
    , DupCount = length(which(duplicated(xx$X1)))
    
    , stringsAsFactors = F)
  
})


filestats_df<- rbindlist(filestats,fill = T, use.names = TRUE)

write_delim(filestats_df,path = paste0(ResultsPath, "/FileStats-Summary.txt")  , delim = "\t")

#stop the cluster to free resources
gc()
stopCluster(cl)


# Parsing Files into respective Fields ------------------------------------

filedetails <- parLapply(cl,counter, function(x) {
  
  FileName = fileNames[[x]]
  
  FilePath = files[[x]]
  
  dat <- read_delim(FilePath,
                    delim = "\t",
                    escape_double = FALSE,
                    col_names = FALSE,
                    trim_ws = T) %>%
    as.data.table()
  
  # Split on Colon   
  dat <- str_split(dat$X1
                   , pattern = ":"
                   , n = 2)
  
  # create data table (New Method)
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
  
  #Stripping the BasePath to Append Cleandataset dir under it to store results
  BasePath<- dirname(FilePath)
  
  #Create a new dir CleanDataset
  # dir.create(paste0(BasePath, "/CleanDataset"))
  
  #Writing Clean files into Results Dir
  write_delim(dat,path = paste0(BasePath, "/Processed-", basename(FilePath))  , delim = "\t")
  
})

#stop the cluster to free resources
gc()
stopCluster(cl)
