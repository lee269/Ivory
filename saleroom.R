library(rvest)
library(xml2)


# baseurl is "https://www.the-saleroom.com/en-gb/search-filter?searchTerm=ivory&page=1&pageSize=240"
# selector .lot-listing-results manually saved as separate html files.
# see second answer in https://stackoverflow.com/questions/34473847/rvest-not-recognizing-css-selector

item <- "h1 a"
auctionhouse <- ".byline a"
lotno <- ".number"
description <- ".description"
date <- "li:nth-child(2)"
estimate <- ".estimate"
openingprice <- "li:nth-child(4)"

pages <- 3
output <- data.frame()



for (i in 1:pages){

  html <- read_html(paste("pg", i, ".html", sep = ""))
  
  item_list <- html %>% html_nodes(item) %>% html_text()
  ah_list <- html %>% html_nodes(auctionhouse) %>% html_text()
  lotno_list <- html %>% html_nodes(lotno) %>% html_text()
  description_list <- html %>% html_nodes(description) %>% html_text()
  date_list <- html %>% html_nodes(date) %>% html_text()
  # estimate_list <- html %>% html_nodes(estimate) %>% html_text()
  op_list <- html %>% html_nodes(openingprice) %>% html_text()

  x <- data.frame(item_list, ah_list, lotno_list, description_list, date_list, op_list) 
  output <- rbind(output, x)
}


