# Load Packages
pkgs <- c(pkgs <- c("readr","stringr","ggplot2","data.table","tidyr", "plyr", "dplyr", "stringdist","data.world","urltools"))
sapply(pkgs, function(x) suppressPackageStartupMessages(require(x, character.only = T)))

Pwdlength <- "C:/Users/ashwin/Downloads/BreachCompilation/Results/Summary-PasswordLength.txt"

# Load large txt file
pwdltable <- read_delim(Pwdlength,
                        delim = "\t",
                        col_names = T) %>%
  as.data.table() 


########################################################################################
#Summary of Password Lenght columns
summary(pwdltable$PasswordLength)

#Plotting histograms of Password length
(ggplot((pwdltable %>% filter(PasswordLength < 40)), aes(x=PasswordLength, y=TotalCount)) + geom_bar(stat = "identity") )

########################################################################################

charfreq <- "C:/Users/ashwin/Downloads/BreachCompilation/Results/CharFrequencytable-Consolidated-Summary.txt"

# Load lSummary charfrequency txt file andf filter records for greater than 1000
charfreqtable <- read_delim(charfreq,
                            delim = "\t",
                            col_names = T) %>%
  as.data.table() %>% filter(TotalRecords > 1000) 

### Clean the Data set
charfreqtable <- charfreqtable %>%
  mutate(EMailDomain = gsub("yaho.|yahoo.|yahoi.|yahooi.|yahool.|yahoom.|yahooo.|yahop.|yahopo.|yahou.|yahpoo.|yahpp.|yahu.|yahuu.|yahyoo.|yahyoo.|yyahoo.|yahaoo.|yah.|atyahoo.|ayahoo.|lyahoo.|tyahoo.|uyahoo.|hyahoo.", "yahoo.", EMailDomain)) %>%
  mutate(EMailDomain = gsub("wal-mart", "walmart", EMailDomain)) %>% 
  mutate(EMailDomain = gsub("^\\.", "", EMailDomain)) %>%
  mutate(EMailDomain = gsub("^\\-", "", EMailDomain)) %>% 
  group_by(EMailDomain) %>%  
  summarise(TotalRecords = sum(TotalRecords), 
            CharacterCount = sum(CharacterCount),
            LowercaseCount = sum(LowercaseCount),
            UppercaseCount = sum(UppercaseCount),
            AlphaNumericCount = sum(AlphaNumericCount),
            NumericCount = sum(NumericCount),
            CyrillicCount=sum(CyrillicCount),
            PunctCount = sum(PunctCount)) 

#### Using URLtools library parse the Emaildomain field
Parsed_domains<-suffix_extract(charfreqtable$EMailDomain)

##Merge the tables with Parsed domains
charfreqtable_parsed <- merge(charfreqtable, Parsed_domains, by.x ="EMailDomain", by.y="host")

########################################################################################
# Joining against Fortune 500 dataset to populate categories

fortune500dataset <- query(
  qry_sql("SELECT * FROM fortune_500_2017_fortune_500"),
  dataset = "aurielle/fortune-500-2017") %>% 
  select ("title","website","sector") %>% 
  mutate(site=gsub(website,pattern ="http://www.",replacement =""))

charfreqtablewithsector <- merge(charfreqtable_parsed, fortune500dataset, by.x ="EMailDomain", by.y="site")


## Gather all the metrics and re-sum
final.data <- charfreqtable_parsed %>%
  gather(Metric, Metric.Score, -EMailDomain, -domain, -suffix) %>%
  group_by(EMailDomain, Metric) %>%
  mutate(Metric.Score2 = sum(as.numeric(Metric.Score))) %>%
  ungroup(.) %>%
  select(-Metric.Score) %>%
  unique(.) %>%
  spread(Metric, Metric.Score2)

average.data <- final.data %>%
  gather(Metric, Metric.Score, -EMailDomain, -domain, -suffix, -TotalRecords) %>%
  mutate(Metric.Score = Metric.Score / TotalRecords) %>%
  spread(Metric, Metric.Score)


sector.data <- final.data %>%
  merge(., sector.df, by = "domain", all.x = T) %>%
  filter(!is.na(Sector))

sector.average.data <- average.data %>%
  merge(., fortune500dataset, by.x ="EMailDomain", by.y="site", all.x = T) %>%
  filter(!is.na(sector))
