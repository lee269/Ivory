library(rvest)
library(xml2)
library(here)

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
image <- "img"

pages <- 3
output <- data.frame()



for (i in 1:pages){
  
  html <- read_html(here("html", paste("pg", i, ".html", sep = "")))
  
  item_list <- html %>% html_nodes(item) %>% html_text()
  ah_list <- html %>% html_nodes(auctionhouse) %>% html_text()
  lotno_list <- html %>% html_nodes(lotno) %>% html_text()
  description_list <- html %>% html_nodes(description) %>% html_text()
  date_list <- html %>% html_nodes(date) %>% html_text()
  # estimate doesnt give the same number of records because of missing values
  # Not sure yet how to cope with that estimate_list <- html %>%
  # html_nodes(estimate) %>% html_text() images also doesnt give the same number
  # because some are 'no image available'
  # img <- html %>% html_nodes("img") %>% html_attr("src") %>% data.frame() %>% filter(. !="/content/sr/images/blank-image.png")
  op_list <- html %>% html_nodes(openingprice) %>% html_text()

  x <- data.frame(item_list, ah_list, lotno_list, description_list, date_list, op_list) 
  output <- rbind(output, x)
}

colnames(output) <- c("item", "auctionhouse", "lotno", "description", "date", "openingprice")
# write.csv(output, here("data", "saleroomdata.csv"))
