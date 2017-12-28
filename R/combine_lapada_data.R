library(here)
library(stringr)
library(dplyr)
library(tm)

source(here("R", "get_lapada_categories.R"))
source(here("R", "get_lapada_items.R"))

# We have built a catalogue dataset using get_lapada_categories. Code is in the
# make_lapada_catalogue.R file. Now we want to extract individual item details
# using the get_lapada_items function.
catalogue <- read.csv(here("data", "catalogue.csv"), stringsAsFactors = FALSE)

# Lets summarise by category
categories <- catalogue %>% 
              group_by(category) %>% 
              summarise(count = n())

# And make a list of them. We might be able to use purrr later to loop through
# each category automatically.
categorieslist <- as.list(categories$category)

# Loop through our categories
for (i in 1:length(categorieslist)) {
      print(paste("Processing", categorieslist[[i]], categories[i, 2], "items"))
  
      # Filter the catalogue for the category of interest
      catitems <- catalogue %>% 
                     filter(str_detect(category, categorieslist[[i]]))
      
      # convert the urls to a list
      items <- get_lapada_items(urls = as.list(catitems$url)) 
      
      # rename artist field to get rid of pesky /
      if ("artist/maker" %in% names(items)) {
      items <- items %>%
              rename(artist_maker = `artist/maker`)
      } else {
        items$artist_maker = "none"
      }
      
      # join item details to the catalogue data and clean up
      catitems <- catitems %>% 
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
      
      # write item data to csv for future processing.
      write.csv(catitems, here("data", paste(categorieslist[[i]], ".csv", sep = "")))

}

