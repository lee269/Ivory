library(rvest)
library(xml2)
library(here)
library(dplyr)
library(purrr)
library(stringr)
library(tidytext)
library(tm)
library(tidyr)

# baseurl <- "https://lapada.org/art-and-antiques/set-of-french-side-tables-in-lacquered-and-painted-chinoiserie-wood-20th-century/"
# html <- read_html(baseurl)

objectdescription <- ":nth-child(3) .page-content"
objclass <- ".classifications li"
# objectcondition <- ":nth-child(4) .page-content"
# material <- "li:nth-child(1) .px"
# dimensions <- "li:nth-child(1) .px"
# country <- "li:nth-child(4) .px a"
# year <- "li:nth-child(5) .px"
# item <- ".m0"
# price <- ".bold"

ld <- read.csv(here("data", "lapadacatalogue.csv"), stringsAsFactors = FALSE)
colnames(ld)[1] <- "id"
urls <- as.list(ld$url[1:100])

html <- urls %>% map(read_html) 

objdesc <- html %>% 
  map(html_nodes, objectdescription) %>% 
  map_df(map_df, ~list(var = .x %>%  html_text()), .id = "id") %>% 
  mutate(id = as.numeric(id)) %>% 
  rename(description = var)

classifications <- html %>% 
                    map(html_nodes, objclass) %>% 
                    map_df(map_df, ~list(var = .x %>%  html_text()), .id = "id") %>% 
                    mutate(id = as.numeric(id)) %>% 
                    mutate(attribute = stripWhitespace(var)) %>% 
                    mutate(attribute = str_trim(attribute)) %>% 
                    mutate(attribute = word(attribute)) %>% 
                    spread(key = attribute, value = var)

x <- ld[1:100, ]

catalogue <- ld[1:100, ] %>% 
              left_join(objdesc) %>% 
              left_join(classifications)


# objcond <- html %>% 
#   map(html_nodes, ":nth-child(4) .page-content") %>% 
#   map_df(map_df, ~list(var = .x %>%  html_text()))

# mat <- html %>% 
#   map(html_nodes, "li:nth-child(1) .px") %>% 
#   map_df(map_df, ~list(var = .x %>%  html_text()))


df <- data.frame(ld$url[1:10], objdesc, objcond)




x <- "hello sailor how are you"
y <- word(x)
y <- str_split(x, " ", n = 2)[[1]][1]
z <- y[[1]]


# Interesting: https://stackoverflow.com/questions/43035598/replacing-missing-value-when-web-scraping-rvest
# git remote add origin https://github.com/lee269/Ivory.git
# git push -u origin master