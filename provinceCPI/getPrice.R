# =========================================================================
# This program combines each CPI from all provinces
# Process - Get price data with special attention to Bangkok
#         - Row-bind every file
#         - Match province name to the correct province code 
#           (This assumes that province names are in alphabetical order)
# =========================================================================

library(readxl)
library(dplyr)
library(haven)

setwd("/Data/CPI")

fileDomain <- list.files("/Data/CPI/", pattern =".xls", full.names = TRUE)

yearVec <- 2006:2015

# Get eat-out price =============================================================
for (i in c(1,2,4:length(fileDomain))) {
  rawData <- read_excel(fileDomain[i], col_names = TRUE)
  eatOutPrice_raw <- rawData[20, 4:13]
  eatOutPrice <- t(eatOutPrice_raw)
  
  rownames(eatOutPrice) <- c()
  colnames(eatOutPrice) <- "eatOutPrice"
  
  province <- substr(sub(".xls", "", fileDomain[i]),15,100000)
  province2 <- sub("_"," ",province)
  
  eatOutPrice <- as.data.frame(cbind(yearVec, eatOutPrice))
  eatOutPrice$provName <- i
  
  outputName <- paste0(paste0("/Data/CPI/eatOutPrice_", province),".csv")
  
  write.csv(eatOutPrice, file = outputName)
  msg <- paste0("Output csv for Changwat ", province2)
  print(msg)
  
  rm(rawData, eatOutPrice_raw, eatOutPrice, outputName, province, province2, msg, i)
}

# special case for bangkok

for (i in 3:3) {
  rawData <- read_excel(fileDomain[i], col_names = TRUE)
  eatOutPrice_raw <- rawData[17, 3:12]
  eatOutPrice <- t(eatOutPrice_raw)
  
  rownames(eatOutPrice) <- c()
  colnames(eatOutPrice) <- "eatOutPrice"
  
  province <- substr(sub(".xls", "", fileDomain[i]),15,100000)
  province2 <- sub("_"," ",province)
  
  eatOutPrice <- as.data.frame(cbind(yearVec, eatOutPrice))
  eatOutPrice$provName <- i
  
  outputName <- paste0(paste0("/Data/CPI/eatOutPrice_", province),".csv")
  
  write.csv(eatOutPrice, file = outputName)
  msg <- paste0("Output csv for Changwat ", province2)
  print(msg)
  
  rm(rawData, eatOutPrice_raw, eatOutPrice, outputName, province, province2, msg, i)
}

# Row bind every file ================================================================

file_eatOutPrice <- list.files("/Data/CPI",
                    pattern = "eatOutPrice_",
                    full.names = TRUE)

# This line may take some time to run
eatOutPrice_all <- lapply(file_eatOutPrice, read.csv, row.names=1)
eatOutPrice_output_wrongProvCode <- bind_rows(eatOutPrice_all)
rm(eatOutPrice_all)

# Match the order with the standardized province code ================================

provinceVec <- c()

for (i in 1:length(file_eatOutPrice)) {
  provinceVec[i] <- sub("_", " ",
                          sub("_", " ", 
                            sub("_", " ", 
                              substr(sub(".xls", "", fileDomain[i]),15,100000))))
  rm(i)
}

provinceOrder <- as.data.frame(provinceVec)
provinceOrder$order <- 1:length(provinceVec)

provinceCode <- read_excel("/Data/Basic_data/Province_match.xlsx")
provinceCode <- provinceCode[,c(1,2)]

provinceMatch <- merge(provinceOrder, provinceCode, 
                       by.x = "provinceVec" ,by.y = "NAME_1")

rm(provinceCode, provinceOrder)

eatOutPrice_output <- merge(eatOutPrice_output_wrongProvCode, provinceMatch, 
                            by.x= "provName", by.y = "order")
rm(eatOutPrice_output_wrongProvCode, provinceMatch)

eatOutPrice_output <- eatOutPrice_output[,-c(1,4)] #drop name order and actual name

write_dta(eatOutPrice_output, path = "/Data/CPI/eatOutPrice.dta")
