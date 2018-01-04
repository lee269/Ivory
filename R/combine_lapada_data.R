library(here)
library(stringr)
library(dplyr)
library(purrr)

source(here("R", "get_lapada_categories.R"))
source(here("R", "get_lapada_items.R"))

# We have built a catalogue dataset using get_lapada_categories. Code is in the
# make_lapada_catalogue.R file. Now we want to extract individual item details
# using the get_lapada_items function.
catalogue <- read.csv(here("data", "catalogue.csv"), stringsAsFactors = FALSE)

files <- list.files(here("data"),pattern = "*.csv",  full.names = TRUE)

catalogue <- files %>% 
  set_names(basename(.)) %>% 
  map(read.csv) %>% 
  bind_rows() %>% 
  filter(category != "fineart" & category != "furniture")

# Lets summarise by category
categories <- catalogue %>% 
              group_by(category) %>% 
              summarise(count = n())

# And make a list of them. We might be able to use purrr later to loop through
# each category automatically.
categorieslist <- as.list(categories$category)

# Loop through our categories
for (i in 36:length(categorieslist)) {
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
        select(-X, -id)
      
      # write item data to csv for future processing.
      write.csv(catitems, here("data", "lapada_items", paste(categorieslist[[i]], ".csv", sep = "")))

}

