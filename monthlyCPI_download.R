# =========================================================================
# This program downloads API files from MOC website and combines price index
# Source  - "https://data.moc.go.th/OpenData/CPIPIndexes"
# Process - download API of 75 provinces
#         - download Beungkan's file
#         - download Bangkok Metropolitan's file
#         - combine provincial data and export as dta
# =========================================================================

library(httr)
library(jsonlite)
library(lubridate)
library(readxl)
library(dplyr)
library(haven)

options(stringsAsFactors = FALSE)

setwd("/Data/monthlyCPI")

# choose price to download =================================================================
id = 1111 #rice
id = 1140 #fruits and vegetables
id = 1160 #non-alcoholic drinks
id = 1220 #eatOutPrice

id = 8200 #food&beverage(excluding fresh food)
id = 9100 #fresh food

id = 2000 #clothes and shoes
id = 2100 #clothes
id = 2200 #shoes

id = 3700 #domestic worker available only from 2012 -2017
id = 4220 #private service

# download API and export by province ====================================================
base1 <- "https://dataapi.moc.go.th/cpip-indexes?province_code="
base2 <- "&index_id="
base3 <- "000000000000&from_year=2003&to_year=2017"

for (i in c(11:27, 30:37, 39:58, 60:67, 70:77, 80:86, 90:96)) {
  myURL <- paste0(base1, i, base2, id, base3)
  
  # get data set
  rawResult <- GET(myURL)
  msg1 <- paste0("Downloaded data for province ", i)
  print(msg1)
  
  textContent <- rawToChar(rawResult$content)
  contentDF <- fromJSON(textContent)
  
  output <- contentDF[,c(3,6,7,8)]
  outputName <- paste0("/Data/monthlyCPI/monthlyCPI_",id,"_", i, ".csv")
  write.csv(output, outputName)
  
  msg2 <- paste0("Output data for province ", i)
  print(msg2)
  
  rm(i, myURL, rawResult, msg1, textContent, contentDF, output, outputName, msg2)
}

base3 <- "000000000000&from_year=2012&to_year=2017"

for (i in 38:38) {
  myURL <- paste0(base1, i, base2, id, base3)
  
  # get data set
  rawResult <- GET(myURL)
  msg1 <- paste0("Downloaded data for province ", i)
  print(msg1)
  
  textContent <- rawToChar(rawResult$content)
  contentDF <- fromJSON(textContent)
  
  output <- contentDF[,c(3,6,7,8)]
  outputName <- paste0("/Data/monthlyCPI/monthlyCPI_",id,"_", i, ".csv")
  write.csv(output, outputName)
  
  msg2 <- paste0("Output data for province ", i)
  print(msg2)
  
  rm(i, myURL, rawResult, msg1, textContent, contentDF, output, outputName, msg2)
}

# Bangkok & vicinity 
# (waiting for moc's reply to get Bangkok's data individually)

base1 <- "https://dataapi.moc.go.th/cpig-indexes?region_id="
base3 <- "000000000000&from_year=2003&to_year=2017"

for (i in 0:0) {
  myURL <- paste0(base1, i, base2, id, base3)
  
  # get data set
  rawResult <- GET(myURL)
  msg1 <- paste0("Downloaded data for province 10")
  print(msg1)
  
  textContent <- rawToChar(rawResult$content)
  contentDF <- fromJSON(textContent)
  
  output <- contentDF[,c(3,6,7,8)]
  outputName <- paste0("/Data/monthlyCPI/monthlyCPI_",id,"_10", ".csv")
  write.csv(output, outputName)
  
  msg2 <- paste0("Output data for province 10")
  print(msg2)
  
  rm(i, myURL, rawResult, msg1, textContent, contentDF, output, outputName, msg2)
}

# combine all provinces ================================================================
myPattern <- paste0("monthlyCPI_", id)
  
allFiles <- list.files("/Data/monthlyCPI", pattern = myPattern, full.names = TRUE)
allFiles_list <- lapply(allFiles, read.csv, row.names=1)
allFiles_output<- bind_rows(allFiles_list)

outputName <- paste0("/Data/monthlyCPI/monthlyCPI_", id, ".dta")
write_dta(allFiles_output, path = outputName)
