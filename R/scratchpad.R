library(rvest)
library(xml2)
library(here)
library(dplyr)

# html <- read_html(here("html", "pg1.html"))

baseurl <- "https://lapada.org/art-and-antiques/set-of-french-side-tables-in-lacquered-and-painted-chinoiserie-wood-20th-century/"
html <- read_html(baseurl)

objectdescription <- ":nth-child(3) .page-content p"
objectcondition <- ":nth-child(4) p"
material <- "li:nth-child(1) .px"
dimensions <- "li:nth-child(1) .px"
country <- "li:nth-child(4) .px a"
year <- "li:nth-child(5) .px"
item <- ".m0"
price <- ".bold"


library(purrr)
ld <- read.csv(here("data", "lapadacatalogue.csv"), stringsAsFactors = FALSE)
urls <- as.list(ld$url[1:10])

html <- urls %>% map(read_html) 

df <- html %>% 
  map(html_nodes, ":nth-child(3) .page-content p") %>% 
  map_df(map_df, ~list(var = .x %>% html_node(":nth-child(3) .page-content p") %>% html_text()))

# Interesting: https://stackoverflow.com/questions/43035598/replacing-missing-value-when-web-scraping-rvest
# git remote add origin https://github.com/lee269/Ivory.git
# git push -u origin master