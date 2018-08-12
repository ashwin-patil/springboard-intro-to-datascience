##ggplot visualization
library(ggplot2)

ggplot(sector.average.data, aes(x=sector, y=CharacterCount)) + geom_boxplot() + theme(axis.text.x = element_text(angle = 90, hjust = 1))

ggplot(sector.average.data, aes(x=sector, y=CharacterCount)) + geom_boxplot() + coord_flip()


#Boxplot for 2 domains for testing
ruvsukdomains = charfreqtable %>% filter(EMailDomain == "gmail.ru" | EMailDomain ==  "gmail.co.uk")

truvsukdomains <- t(ruvsukdomains)

ggplot (t(ruvsukdomains), aes(EMailDomain,CharacterCount)) + geom_bar(stat = "identity")


ggplot (t(ruvsukdomains)) + geom_boxplot() + facet_wrap(~EMailDomain)

#Box Plots comparision of 2 EmailDOmains
ggplot(fildetails_df, aes(x=EMailDomain, y=lower.alpha.count)) + geom_boxplot() 
ggplot(fildetails_df, aes(x=EMailDomain, y=upper.alpha.count)) + geom_boxplot()
ggplot(fildetails_df, aes(x=EMailDomain, y=numeric.count)) + geom_boxplot()
ggplot(fildetails_df, aes(x=EMailDomain, y=alphanumeric.count)) + geom_boxplot()
ggplot(fildetails_df, aes(x=EMailDomain, y=punct.count)) + geom_boxplot()
ggplot(fildetails_df, aes(x=EMailDomain, y=cyrillic.count)) + geom_boxplot()
ggplot(fildetails_df, aes(x=EMailDomain, y=total.count)) + geom_boxplot()


#Top 15 Domains in the datasets.
charfreqtabletop15 <- charfreqtable <- charfreqtable %>%
  mutate(EMailDomain = gsub("yaho.|yahoo.|yahoi.|yahooi.|yahool.|yahoom.|yahooo.|yahop.|yahopo.|yahou.|yahpoo.|yahpp.|yahu.|yahuu.|yahyoo.|yahyoo.|yyahoo.|yahaoo.|yah.|atyahoo.|ayahoo.|lyahoo.|tyahoo.|uyahoo.|hyahoo.", "yahoo.", EMailDomain)) %>%
  mutate(EMailDomain = gsub("wal-mart", "walmart", EMailDomain)) %>% 
  mutate(EMailDomain = gsub("^\\.", "", EMailDomain)) %>%
  mutate(EMailDomain = gsub("^\\-", "", EMailDomain)) %>% 
  group_by(EMailDomain) %>%  
  summarise(TotalRecords = sum(TotalRecords)) %>% 
  mutate(Percentage=TotalRecords/sum(charfreqtable$TotalRecords)*100) %>%  
  mutate(EMailDomain=factor(EMailDomain)) %>% 
  arrange(desc(TotalRecords)) %>% 
  top_n(15)

ggplot(charfreqtabletop15, aes(x=reorder(EMailDomain, Percentage), y=Percentage)) + geom_bar(stat = "identity")  +
  coord_flip() + labs(y = "Percentage of Total Dataset", x = "Top 15 EmailDomains") 




##ggplot visualization
library(ggplot2)

#Boxplots for Avg Password length across various sectors.
ggplot(sector.average.data, aes(x=sector, y=CharacterCount)) + geom_boxplot() + theme(axis.text.x = element_text(angle = 90, hjust = 1))

ggplot(sector.average.data, aes(x=sector, y=CharacterCount)) + geom_boxplot() + coord_flip()

#BarChart/Distribution on domains per Sector.
sectorbysite <- charfreqtablewithsector %>% 
  group_by(sector) %>% 
  summarise(NoofCompanies=n_distinct(title)) %>% 
  arrange(desc(NoofCompanies))

ggplot(sectorbysite, aes(x=reorder(sector,NoofCompanies), y=NoofCompanies)) + geom_bar(stat = "identity") + coord_flip()