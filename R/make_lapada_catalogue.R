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

# These are the top level categories - some kept failing
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

# so heres the fine art category broken down to see if that works.
# catpages <- list("https://lapada.org/art-and-antiques/fine-art-sculpture/drawings-pastels",
#                  "https://lapada.org/art-and-antiques/fine-art-sculpture/illustrations",
#                  "https://lapada.org/art-and-antiques/fine-art-sculpture/mixed-media",
#                  "https://lapada.org/art-and-antiques/fine-art-sculpture/paintings",
#                  "https://lapada.org/art-and-antiques/fine-art-sculpture/photography",
#                  "https://lapada.org/art-and-antiques/fine-art-sculpture/portrait-miniatures",
#                  "https://lapada.org/art-and-antiques/fine-art-sculpture/prints-multiples",
#                  "https://lapada.org/art-and-antiques/fine-art-sculpture/sculpture")

#  breakdown of furniture category
catpages <- list("https://lapada.org/art-and-antiques/furniture/beds-day-beds",
                 "https://lapada.org/art-and-antiques/furniture/boxes-caddies",
                 "https://lapada.org/art-and-antiques/furniture/cabinets-bookcases",
                 "https://lapada.org/art-and-antiques/furniture/canterburys",
                 "https://lapada.org/art-and-antiques/furniture/chairs",
                 "https://lapada.org/art-and-antiques/furniture/chests-trunks",
                 "https://lapada.org/art-and-antiques/furniture/decorative-objects",
                 "https://lapada.org/art-and-antiques/furniture/desks-writing-tables",
                 "https://lapada.org/art-and-antiques/furniture/dressers-and-dresser-bases",
                 "https://lapada.org/art-and-antiques/furniture/mirrors",
                 "https://lapada.org/art-and-antiques/furniture/screens",
                 "https://lapada.org/art-and-antiques/furniture/sideboards-buffets",
                 "https://lapada.org/art-and-antiques/furniture/sofas-settees-benches",
                 "https://lapada.org/art-and-antiques/furniture/stools",
                 "https://lapada.org/art-and-antiques/furniture/tables",
                 "https://lapada.org/art-and-antiques/furniture/wardrobes-linen-presses",
                 "https://lapada.org/art-and-antiques/furniture/whatnots",
                 "https://lapada.org/art-and-antiques/furniture/wine-coolers-cellarettes")


# And heres some values for the category variables. We could make them more descriptive if we want

#  top level category names
# catnames <- list("antiquities", "architectural", "books", "ceramics", "clocks", "coins",
#                  "collectables", "fineart", "furniture", "jewellery", "lighting",
#                  "military", "nautical", "textiles", "silver", "tribal")

# and fine art sub categories
# catnames <- list("fineart-drawings", "fineart-illustrations", "fineart-mixedmedia",
#                  "fineart-paintings", "fineart-photography", "fineart-portratis",
#                  "fineart-prints", "fineart-sculpture")

# furniture sub categories
catnames <- list("furniture-beds", "furniture-boxes", "furniture-cabinets", "furniture-canterburys",
                 "furniture-chairs", "furniture-chests", "furniture-decorativeobjects",
                 "furniture-desks", "furniture-dressers", "furniture-mirrors", "furniture-screens",
                 "furniture-sideboards", "furniture-sofas", "furniture-stools", "furniture-tables",
                 "furniture-wardrobes", "furniture-whatnots", "furniture-winecoolers")


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

