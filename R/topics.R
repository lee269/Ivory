
library(here)
library(readxl)
library(dplyr)
library(stringr)
library(tm)
library(tidytext)
library(tidyr)
library(topicmodels)

fname <- "Response master spreadsheet 040118 - non sensitive - v1 - final.xlsx"

response <- read_excel(here("data", "consultation", fname), sheet = "text responses", range="A1:AD5716")

x <- colnames(response)
x[12] <- "Q101"
x[16] <- "Q131"
x[29] <- "Q261"
y <- str_extract(x, "Q[0-9]+")
y[1] <- "id"

colnames(response) <- y #mote this creates dup colnames


responselong <- response%>% 
                gather(key = id1, value = "text")

rawtxt <- responselong %>% 
            filter(!is.na(text), id1 != "id") %>% 
            select(text)


write.csv(rawtxt, here("data", "consultation", "allqs.txt"), col.names = FALSE, row.names = FALSE)


