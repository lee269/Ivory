library(here)
library(purrr)
library(dplyr)

# Load up some functions
source(here("R", "get_lapada_categories.R"))
source(here("R", "get_lapada_items.R"))

# Just for reference, here is the url for the full catalogue link
fullcatlink <- "https://lapada.org/art-and-antiques/"

# And here is the list of the category pages. We will use these to add a
# 'category' variable so we can classify the items in a bit more detail.
# catpages <- list(antiquities = "https://lapada.org/art-and-antiques/antiquities",
#                  architectural = "https://lapada.org/art-and-antiques/architectural-garden-items",
#                  books = "https://lapada.org/art-and-antiques/books-maps",
#                  ceramics = "https://lapada.org/art-and-antiques/ceramics-glass",
#                  clocks = "https://lapada.org/art-and-antiques/clocks-barometers",
#                  coins = "https://lapada.org/art-and-antiques/coins-banknotes-medals",
#                  collectables = "https://lapada.org/art-and-antiques/collectables",
#                  fineart = "https://lapada.org/art-and-antiques/fine-art-sculpture",
#                  furniture = "https://lapada.org/art-and-antiques/furniture",
#                  jewellery = "https://lapada.org/art-and-antiques/jewellery-watches",
#                  lighting = "https://lapada.org/art-and-antiques/lighting",
#                  military = "https://lapada.org/art-and-antiques/military-antiques",
#                  nautical = "https://lapada.org/art-and-antiques/nautical-maritime-antiques",
#                  textiles = "https://lapada.org/art-and-antiques/rugs-carpets-textiles",
#                  silver = "https://lapada.org/art-and-antiques/silver",
#                  tribal = "https://lapada.org/art-and-antiques/tribal-ethnographical-art")

catpages <- list("https://lapada.org/art-and-antiques/fine-art-sculpture/drawings-pastels",
                 "https://lapada.org/art-and-antiques/fine-art-sculpture/illustrations",
                 "https://lapada.org/art-and-antiques/fine-art-sculpture/mixed-media",
                 "https://lapada.org/art-and-antiques/fine-art-sculpture/paintings",
                 "https://lapada.org/art-and-antiques/fine-art-sculpture/photography",
                 "https://lapada.org/art-and-antiques/fine-art-sculpture/portrait-miniatures",
                 "https://lapada.org/art-and-antiques/fine-art-sculpture/prints-multiples",
                 "https://lapada.org/art-and-antiques/fine-art-sculpture/sculpture")


# And heres some values for the category variables. We could make them more descriptive if we want
# catnames <- list("antiquities", "architectural", "books", "ceramics", "clocks", "coins",
#                  "collectables", "fineart", "furniture", "jewellery", "lighting",
#                  "military", "nautical", "textiles", "silver", "tribal")
catnames <- list("fineart-drawings", "fineart-illustrations", "fineart-mixedmedia",
                 "fineart-paintings", "fineart-photography", "fineart-portratis",
                 "fineart-prints", "fineart-sculpture")



# map2 is the key (from purrr). We apply 2 values (the cat urls and the cat
# names) to the get_lapada_categories function to make a dataset with all the data plus
# a category var to help identify them
catalogue <- map2_df(catpages, catnames, ~ get_lapada_categories(baseurl = .x, category = .y))

# Lets write it out to a file before we lose it
 write.csv(catalogue, here("data", "testbooks.csv"))

 
# Now lets test whether we got everything
x <- catalogue %>% 
      group_by(category) %>% 
      summarise(count = n())

