# =========================================================================
# This program downloads excel files from NSO website
# link for provincial rainfall data : http://service.nso.go.th/nso/web/statseries/statseries27.html
# Process - copy source code from the website and pick up only the necessary section (manually)
#         - clean text file and get download links
#         - download 54 files (Not all provinces have measurement station)
#         - download Bangkok's file
# =========================================================================

library(readr)
library(dplyr)
library(stringr)
library(readxl)
library(haven)

downloadLink <- read_csv("T:/Data/rainfall/rainfall_sourceCode_download.txt", 
                             col_names = FALSE)
data <- na.omit(downloadLink)

data$after <- gsub(".*tables/","",data$X1)
data$before <- sub("xls.*","", data$after)

data$wrongClass <- substr(data$before, 1 ,1)
data <- data[data$wrongClass!="<", ]

rainData <- filter(data, str_detect(data$before, "rain"))

base <- "http://service.nso.go.th/nso/web/statseries/tables/"

rainData$link <- paste0(base, paste0(rainData$before, "xls"))

# construct file names ===================================================

rainData$provName <- sub("/rain.*", "", substr(rainData$before, 7, 100000))
rainData$dest <- paste0("T:/Data/rainfall/rain_", paste0(rainData$provName, ".xls"))

bangkokDest <- "T:/Data/rainfall/rain_Bangkok.xls"

# download excel files ===================================================
for (i in 1:length(rainData$link)) {
  download.file(rainData$link[i], rainData$dest[i], 
                mode = "wb") #excel is binary
}

bangkokLink <- paste0(base, "11000_Bangkok/rain-46-58.xls")

download.file(bangkokLink, bangkokDest, mode = "wb")

# get rainfall data from excel files ====================================
setwd("/Data/rainfall")

fileDomain <- list.files("/Data/rainfall/", pattern =".xls", full.names = TRUE)

yearVec <- 2003:2015

# Get eat-out price =============================================================
for (i in 1:length(fileDomain)) {
  rawData <- read_excel(fileDomain[i], col_names = TRUE)
  totalRain1 <- t(rawData[8, 2:14])
  totalRain2 <- t(rawData[14, 2:14])
  totalRain3 <- t(rawData[20, 2:14])
  totalRain4 <- t(rawData[26, 2:14])
  totalRain5 <- t(rawData[32, 2:14])
  rainyDay1  <- t(rawData[9, 2:14])
  rainyDay2  <- t(rawData[15, 2:14])
  rainyDay3  <- t(rawData[21, 2:14])
  rainyDay4  <- t(rawData[27, 2:14])
  rainyDay5  <- t(rawData[33, 2:14])
  
  rownames(totalRain1) <- c()
  rownames(totalRain2) <- c()
  rownames(totalRain3) <- c()
  rownames(totalRain4) <- c()
  rownames(totalRain5) <- c()
  rownames(rainyDay1)  <- c()
  rownames(rainyDay2)  <- c()
  rownames(rainyDay3)  <- c()
  rownames(rainyDay4)  <- c()
  rownames(rainyDay5)  <- c()
  colnames(totalRain1) <- "totalRain1"
  colnames(totalRain2) <- "totalRain2"
  colnames(totalRain3) <- "totalRain3"
  colnames(totalRain4) <- "totalRain4"
  colnames(totalRain5) <- "totalRain5"
  colnames(rainyDay1)  <- "rainyDay1"
  colnames(rainyDay2)  <- "rainyDay2"
  colnames(rainyDay3)  <- "rainyDay3"
  colnames(rainyDay4)  <- "rainyDay4"
  colnames(rainyDay5)  <- "rainyDay5"
  
  province <- substr(sub(".xls", "", fileDomain[i]),21,100000)
  province_clean <- sub("_", " ", sub("_", " ", sub("_"," ",province)))
  
  rainfall <- as.data.frame(cbind(yearVec, 
                                  totalRain1, totalRain2, totalRain3, totalRain4, totalRain5,
                                  rainyDay1, rainyDay2, rainyDay3, rainyDay4, rainyDay5))
  rainfall$provName <- province_clean
  
  outputName <- paste0(paste0("/Data/rainfall/rain_", province),".csv")
  
  write.csv(rainfall, file = outputName)
  msg <- paste0("Output csv for Changwat ", province_clean)
  print(msg)
  
  rm(rawData, totalRain1, totalRain2, totalRain3, totalRain4, 
     rainyDay1, rainyDay2, rainyDay3, rainyDay4,
     province, province_clean, rainfall, outputName,msg, i)
}

# Row bind every file ================================================================

file_rainfall <- list.files("/Data/rainfall",
                               pattern = ".csv",
                               full.names = TRUE)

# This line may take some time to run
rainfall_all <- lapply(file_rainfall, read.csv, row.names=1)
rainfall_output_provName <- do.call("rbind", rainfall_all)

# Match the order with the standardized province code ================================

provinceVec <- c()

for (i in 1:length(file_rainfall)) {
  provinceVec[i] <- sub("_", " ",
                        sub("_", " ", 
                            sub("_", " ", 
                                substr(sub(".xls", "", fileDomain[i]),21,100000))))
  rm(i)
}

provinceOrder <- as.data.frame(provinceVec)
provinceOrder$order <- 1:length(provinceVec)

provinceCode <- read_excel("/Data/Basic_data/Province_match.xlsx")
provinceCode <- provinceCode[,c(1,2)]

provinceMatch <- merge(provinceOrder, provinceCode, 
                       by.x = "provinceVec" ,by.y = "NAME_1")

rm(provinceCode, provinceOrder)

rainfall_output <- merge(rainfall_output_provName, provinceMatch, 
                          by.x= "provName", by.y = "provinceVec",
                         all.x = TRUE)

rm(rainfall_output_provName, provinceMatch)

write_dta(rainfall_output, path = "/Data/rainfall/rainfall.dta")
#issue: missing province name Nan

unique(rainfall_output_provName$provName)

