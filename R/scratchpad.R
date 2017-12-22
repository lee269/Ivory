library(rvest)
library(xml2)
library(here)
library(dplyr)

html <- read_html(here("html", "pg1.html"))

baseurl <- "https://lapada.org/art-and-antiques/"
html <- read_html(baseurl)

url <- html %>% 
       html_nodes(".item a") %>% 
       html_attr("href") %>% 
       unique() %>% 
       data.frame() %>% 
       filter(. !=gsub(pattern = "https", replacement = "http", x = baseurl))



# Interesting: https://stackoverflow.com/questions/43035598/replacing-missing-value-when-web-scraping-rvest
# git remote add origin https://github.com/lee269/Ivory.git
# git push -u origin master