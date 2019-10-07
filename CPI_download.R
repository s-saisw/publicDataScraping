# =========================================================================
# This program downloads excel files from NSO website
# link for provincial CPI data : "http://service.nso.go.th/nso/web/statseries/statseries25.html"
# Process - copy source code from the website (manually)
#         - pick up only the necessary section and paste to CPI_downloadLink.txt (manually)
#         - clean text file and get download links
#         - download 75 files (excluding bangkok and Beungkan)
#         - download Bangkok's file
# =========================================================================

library(readr)

CPI_downloadLink <- read_csv("T:/Data/CPI/CPI_downloadLink.txt", 
                              col_names = FALSE)

data <- na.omit(CPI_downloadLink)

data$x2 <- substr(data$X1, 15, 10000000)
data <- data[data$x2!="", ]
data <- data[-c(26, 44, 64), ] #manually delete unnessary rows

data$x3 <- sub("xls.*","", data$x2)

base <- "http://service.nso.go.th/nso/web/statseries/"
data$link <- paste0(base, paste0(data$x3, "xls"))

bangkokLink <- paste0(base, "tables/11000_Bangkok/19.1.1.xls")

# construct file names ===================================================

data$x4 <- substr(data$x3, 14, 100000)
data$x5 <- sub("/19.1.1.", "", data$x4)
data$dest <- paste0("T:/Data/CPI/CPI_", paste0(data$x5, ".xls"))

bangkokDest <- "T:/Data/CPI/CPI_Bangkok.xls"

# download excel files ===================================================
for (i in 1:length(data$link)) {
  download.file(data$link[i], data$dest[i], 
                mode = "wb") #excel is binary
}

download.file(bangkokLink, bangkokDest, mode = "wb")
