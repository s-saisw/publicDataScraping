# publicDataScraping
Downloading and cleaning

## Provincial CPI data (annual, 2006-2015)
- Source: http://service.nso.go.th/nso/web/statseries/statseries25.html
- Variable(s): eatOutPrice (CPI for food consumed at restaurants)
- List of files: CPI_downloadSourceCode.txt, CPI_download.R, getPrice.R

## Provincial CPI data (monthly, 2003-2017)
- Source: https://data.moc.go.th/OpenData/CPIPIndexes
- List of files: monthlyCPI_download.R
- How to use: 
    1. set id for the price you want to download (Details below)
    2. the rest is automated :blush:
    
id  | price
---- | -------------
1111 | rice
1140 | fruits and vegetables
1160 | non-alcoholic drinks
1220 | food consumption at restaurants
2000 | clothes and shoes
2100 | clothes
2200 | shoes
3700 | domestic workers
4220 | private service
8200 | food and beverage (excluding raw ingredients)
9100 | food and beverage (raw ingredients only)
