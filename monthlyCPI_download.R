library(httr)
library(jsonlite)
library(lubridate)

options(stringsAsFactors = FALSE)

setwd("/Data/monthlyCPI")

# construct URL ============================================================================
provinceCode <- read_excel("/Data/Basic_data/Province_match.xlsx")
provinceCodeVec <- unique(provinceCode$code)
rm(provinceCode)

provinceCode_exceptBangkok <- provinceCodeVec[-c(1)]

id = 122 #eatOutPrice
i=13

base1 <- "https://dataapi.moc.go.th/cpip-indexes?province_code="
base2 <- "&index_id="
base3 <- "0000000000000&from_year=2003&to_year=2017"

#https://dataapi.moc.go.th/cpip-indexes?province_code=13&index_id=1220000000000000&from_year=2003&to_year=2017"

#c(11:27,30:58, 60:67, 70:77, 80:86, 90:96)

#error: 10, 38

for (i in c(11:27,30:58, 60:67, 70:77, 80:86, 90:96)) {
  myURL <- paste0(base1, i, base2, id, base3)
  
  # get data set
  rawResult <- GET(myURL)
  msg1 <- paste0("Downloaded data for province ", i)
  print(msg1)
  
  textContent <- rawToChar(rawResult$content)
  contentDF <- fromJSON(textContent)
  
  output <- contentDF[,c(3,6,7,8)]
  outputName <- paste0("/Data/monthlyCPI/monthlyCPI_", i, ".csv")
  write.csv(output, outputName)
  
  msg2 <- paste0("Output data for province ", i)
  print(msg2)
  
  rm(i, myURL, rawResult, msg1, textContent, contentDF, output, outputName, msg2)
}


# print(myURL)
# 
# name
# 
# 
# ?paste0
# myURL <- "https://dataapi.moc.go.th/cpip-indexes?province_code=13&index_id=1220000000000000&from_year=2003&to_year=2017"
# 
# rawResult <- GET(myURL)
# 
# View(rawResult)
# names(rawResult)
# 
# textContent <- rawToChar(rawResult$content)
# contentDF <- fromJSON(textContent)
# 
# output <- contentDF[,c(3,6,7,8)]
# 
# write.csv(output, "/Data/monthlyCPI/monthlyCPI_13.csv")
# 
# head(contentDF)
# 
# head(textContent)
# rawResult$content
# ?GET

