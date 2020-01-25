# =========================================================================
# This program downloads excel files from NSO website
# link for number of firms: http://service.nso.go.th/nso/web/statseries/statseries16.html
# Process - copy source code from the website and pick up only the necessary section (manually)
#         - clean text file and get download links
#         - download 54 files (Not all provinces have measurement station)
#         - download Bangkok's file
# =========================================================================

setwd("/Data/firmNumber")

library(readr)
library(dplyr)
library(stringr)
library(readxl)
library(haven)

base <- "http://service.nso.go.th/nso/web/statseries/tables/"
diskDomain <- "/Data/firmNumber"
yearVec <- 2005:2014 #period this data set covers

# download excel files ===================================================

downloadLink <- read_csv("T:/Data/firmNumber/firmNumber_downloadSourceCode.txt", 
                         col_names = FALSE)
data <- na.omit(downloadLink)

data$target <- sub("xls.*","", gsub(".*tables/","",data$X1))
data$wrongClass <- substr(data$target, 1 ,1)
data <- data[data$wrongClass!="<", ]

data$link <- paste0(base, paste0(data$target, "xls"))

# construct file names 
data$provName <- sub("/11.2.*", "", substr(data$target, 7, 100000))
data$dest <- paste0(diskDomain, "/firmNumber_", data$provName, ".xls")

for (i in 1:length(data$link)) {
  download.file(data$link[i], data$dest[i], 
                mode = "wb") #excel is binary
}

bangkokDest <- paste0(diskDomain, "/firmNumber_Bangkok.xls" )

bangkokLink <- paste0(base, "11000_Bangkok/11.2.xls")

download.file(bangkokLink, bangkokDest, mode = "wb")

# get data from excel files ====================================

fileDomain <- list.files(diskDomain, pattern =".xls", full.names = TRUE)

# every province except Beungkan
for (i in c(1,2,3,5:length(fileDomain))) {
  rawData <- read_excel(fileDomain[i], col_names = TRUE)
  
  province_raw <- substr(sub(".xls", "", fileDomain[i]),29,100000)
  
  v1 <- t(rawData[8, 2:11])
  v2 <- t(rawData[9, 2:11])
  v3 <- t(rawData[10, 2:11])
  v4 <- t(rawData[11, 2:11])
  v5 <- t(rawData[12, 2:11])
  
  varlist <- list(v1, v2, v3, v4, v5)
  varName <- c("number", "capital", "worker", "workerMale", "workerFemale")
  
  df <- as.data.frame(do.call("cbind", varlist),
                      row.names = 1:length(yearVec))
  colnames(df) <- varName
  df$year <- yearVec
  df$provRaw <- province_raw
  
  outputName <- paste0(diskDomain, "/firmNumber_", province_raw,".csv")

  write.csv(df, file = outputName)
  msg <- paste0("Output csv for Changwat ", province_raw)
  print(msg)
  
  rm(rawData, province_raw, v1, v2, v3, v4, v5, varlist, varName, df, outputName, msg, i)
}

# special case for Beung kan

yearVec <- 2011:2014

for (i in 4:4) {
  rawData <- read_excel(fileDomain[i], col_names = TRUE)
  
  province_raw <- substr(sub(".xls", "", fileDomain[i]),29,100000)
  
  v1 <- t(rawData[8, 4:7])
  v2 <- t(rawData[9, 4:7])
  v3 <- t(rawData[10, 4:7])
  v4 <- t(rawData[11, 4:7])
  v5 <- t(rawData[12, 4:7])
  
  varlist <- list(v1, v2, v3, v4, v5)
  varName <- c("number", "capital", "worker", "workerMale", "workerFemale")
  
  df <- as.data.frame(do.call("cbind", varlist),
                      row.names = 1:length(yearVec))
  colnames(df) <- varName
  df$year <- yearVec
  df$provRaw <- province_raw
  
  outputName <- paste0(diskDomain, "/firmNumber_", province_raw,".csv")
  
  write.csv(df, file = outputName)
  msg <- paste0("Output csv for Changwat ", province_raw)
  print(msg)
  
  rm(rawData, province_raw, v1, v2, v3, v4, v5, varlist, varName, df, outputName, msg, i)
}

# Row bind every file ================================================================

csvFile <- list.files(diskDomain, pattern = ".csv", full.names = TRUE)

# This line may take some time to run
csvFileList <- lapply(csvFile, read.csv, row.names=1)
output_provRaw<- do.call("rbind", csvFileList)

# fix province code for changwat Nan
output_provRaw$provString = as.character(output_provRaw$provRaw) 
output_provRaw$provFix    = ifelse(is.na (output_provRaw$provString) == TRUE, "Nan", 
                                output_provRaw$provString)

output_provRaw$provClean = sub("_", " ", 
                               sub("_", " ", 
                                   sub("_", " ", output_provRaw$provFix)))

# prepare the merge file
provinceCode <- read_excel("/Data/Basic_data/Province_match.xlsx")
provinceCode <- provinceCode[,c(1,2)]

# merge
output <- merge(output_provRaw, provinceCode, 
                         by.x= "provClean", by.y = "NAME_1",
                         all.x = TRUE)
output <- select(output, 
          province = code, year, number, capital, worker, workerMale, workerFemale)

write_dta(output, path = paste0(diskDomain, "/firmNumber.dta"))
