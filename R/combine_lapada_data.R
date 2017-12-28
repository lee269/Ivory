library(here)
library(stringr)
library(dplyr)
library(tm)

source(here("R", "get_lapada_items.R"))

catalogue <- read.csv(here("data", "catalogue.csv"), stringsAsFactors = FALSE)


ivory <- catalogue %>% 
      filter(str_detect(item, "ivory"))

items <- get_lapada_items(urls = as.list(ivory$url)) 

items <- items %>% 
        rename(artist_maker = `artist/maker`)



ivory <- ivory %>% 
        left_join(items, by = c("url")) %>% 
        select(-X, -id) %>%
        mutate(description = stripWhitespace(description),
               artist_maker = stripWhitespace(artist_maker),
               country = stripWhitespace(country),
               diameter = stripWhitespace(diameter),
               dimensions = stripWhitespace(dimensions),
               material = stripWhitespace(material),
               period = stripWhitespace(period),
               Style = stripWhitespace(Style),
               type = stripWhitespace(type),
               year = stripWhitespace(year)) %>%
        rename(style = Style) %>% 
        mutate(description = str_replace(string = description, pattern = "Object Description", replacement = ""),
               country = str_replace(string = country, pattern = "country", replacement = ""),
               diameter = str_replace(string = diameter, pattern = "diameter", replacement = ""),
               dimensions = str_replace(string = dimensions, pattern = "dimensions", replacement = ""),
               material = str_replace(string = material, pattern = "material", replacement = ""),
               period = str_replace(string = period, pattern = "period", replacement = ""),
               style = str_replace(string = style, pattern = "Style", replacement = ""),
               type = str_replace(string = type, pattern = "type", replacement = ""),
               year = str_replace(string = year, pattern = "year", replacement = ""))
        
  
        