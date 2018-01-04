library(here)
library(dplyr)
library(purrr)
library(tm)


files <- list.files(here("data", "lapada_items"), full.names = TRUE)

# Make a single dataset from the contents of the lapada_items folder. Some files
# have a Style var and some style. We use coalesce to merge them into one single
# var

fullcatalogue <- files %>% 
                  set_names(basename(.)) %>% 
                  map(read.csv) %>% 
                  bind_rows() %>% 
                  mutate(style2 = coalesce(style, Style)) %>% 
                  select(-style, -Style) %>% 
                  rename(style = style2)


# Now to do some cleaning up of the text
fullcatalogue <- fullcatalogue %>% 
                  mutate(description = stripWhitespace(description),
                         artist_maker = stripWhitespace(artist_maker),
                         country = stripWhitespace(country),
                         diameter = stripWhitespace(diameter),
                         dimensions = stripWhitespace(dimensions),
                         material = stripWhitespace(material),
                         period = stripWhitespace(period),
                         style = stripWhitespace(style),
                         type = stripWhitespace(type),
                         year = stripWhitespace(year)) %>%
                    mutate(description = str_replace(string = description, pattern = "Object Description", replacement = ""),
                           country = str_replace(string = country, pattern = "country", replacement = ""),
                           diameter = str_replace(string = diameter, pattern = "diameter", replacement = ""),
                           dimensions = str_replace(string = dimensions, pattern = "dimensions", replacement = ""),
                           material = str_replace(string = material, pattern = "material", replacement = ""),
                           period = str_replace(string = period, pattern = "period", replacement = ""),
                           style = str_replace(string = style, pattern = "Style", replacement = ""),
                           type = str_replace(string = type, pattern = "type", replacement = ""),
                           year = str_replace(string = year, pattern = "year", replacement = ""))

write.csv(fullcatalogue, here("data", "fullcatalogue.csv"))


x <- fullcatalogue %>% 
      group_by(category) %>% 
      summarise(count = n())



