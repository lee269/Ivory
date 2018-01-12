# from https://cran.r-project.org/web/packages/tidytext/vignettes/tidytext.html

library(dplyr)
library(stringr)
library(tidytext)
library(ggplot2)

datafile <- "G:/data/Current/Ivory/emails.csv"
rawdata <- read.csv(datafile, header = TRUE, stringsAsFactors = FALSE)

colnames(rawdata) <- c("doc_id","subject","text")

tidy_emails <- rawdata %>% 
                unnest_tokens(word, text)

data("stop_words")

cleaned_emails <- tidy_emails %>% 
                  anti_join(stop_words)

# most common words
cleaned_emails %>% count(word, sort = TRUE)

bing <- get_sentiments("bing")

sent <- cleaned_emails %>% 
        inner_join(bing) %>% 
        count(word, index = doc_id, sentiment) %>% 
        spread(sentiment, n, fill = 0) %>% 
        mutate(sentiment = positive - negative)

ggplot(sent, aes(index, sentiment, fill= index)) +
      geom_bar(stat = "identity")

bing_word_counts <- cleaned_emails %>% 
                    inner_join(bing) %>% 
                    count(word, sentiment, sort = TRUE) %>% 
                    ungroup()

