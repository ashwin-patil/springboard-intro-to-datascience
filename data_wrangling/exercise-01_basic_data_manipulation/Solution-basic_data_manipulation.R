#Make sure to set the working directory where csv dataset is stored
# Load dataset as dataframe from csv for cleaning
refine_original <- read.csv("refine_original.csv")

#Viewing Structure of the dataset
str(refine_original)

#Viwing dimensions of the dataset
dim(refine_original)

#print the column names of dataset
colnames(refine_original)

#Making all values to lowercase for transformation
refine_original$company<-tolower(refine_original$company)
refine_original$company<-str_trim(refine_original$company)

#Print the unique company values post transformation
unique(tolower(refine_original$company))

#load stringr package for string manipulation
library(stringr)

#Question01 - Clean up Brand names : Key-value string replacements for unique values.
refine_original$company<-str_replace(refine_original$company,"phillips","philips")
refine_original$company<-str_replace(refine_original$company,"phllips","philips")
refine_original$company<-str_replace(refine_original$company,"phillps","philips")
refine_original$company<-str_replace(refine_original$company,"fillips","philips")
refine_original$company<-str_replace(refine_original$company,"phlips","philips")
refine_original$company<-str_replace(refine_original$company,"akz0","akzo")
refine_original$company<-str_replace(refine_original$company,"ak z0","akzo")
refine_original$company<-str_replace(refine_original$company,"unilver","unilever")

#load tidyr library to use separate for data manipulation
library(tidyr)


#Question02-Separate Product code and Product number into seprate columns : Separate function 
refine_original<-separate(refine_original, col = Product.code...number, into = c("product_code", "product_number"), sep = "-")

#load dplyr library to use mutate for data manipulation
library(dplyr)

#Question03- Add Product categories : mutate function to add new column product_code
refine_original <- refine_original %>% 
  mutate(product_category=if_else(product_code=="p","Smartphone",
                          if_else(product_code=="v","TV",
                          if_else(product_code=="x","Laptop",
                           if_else(product_code=="q","Tablet","NA")))))
         
#Question04-Add full address for geocoding : unite function
refine_original<- unite(refine_original, full_address, address, city,country,sep = ",")

#Question05-To create dummy variables for company and product category : mutate function
refine_clean <- refine_original %>% 
  mutate(company_philips=if_else(company=="philips",1,0)) %>% 
  mutate(company_akzo=if_else(company=="akzo",1,0)) %>% 
  mutate(company_unilever=if_else(company=="unilever",1,0)) %>% 
  mutate(company_van_houten=if_else(company=="van houten",1,0)) %>% 
  mutate(product_smartphone=if_else(product_category=="Smartphone",1,0)) %>% 
  mutate(product_tv=if_else(product_category=="TV",1,0)) %>% 
  mutate(product_laptop=if_else(product_category=="Laptop",1,0)) %>% 
  mutate(product_tablet=if_else(product_category=="Tablet",1,0))
                                  
#writing the output clean file after all transformation
write.csv(refine_clean,"refine_clean.csv")
