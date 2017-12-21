library(rvest)
library(xml2)
library(here)
library(dplyr)

html <- read_html(here("html", "pg1.html"))

img <- html %>% 
       html_nodes("img") %>% 
       html_attr("src") %>% 
       data.frame() %>% 
       filter(. !="/content/sr/images/blank-image.png")



# Interesting: https://stackoverflow.com/questions/43035598/replacing-missing-value-when-web-scraping-rvest
# git remote add origin https://github.com/lee269/Ivory.git
# git push -u origin master