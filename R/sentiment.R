# from https://cran.r-project.org/web/packages/tidytext/vignettes/tidytext.html

library(dplyr)
library(stringr)
library(tidytext)
library(ggplot2)
library(here)
library(wordcloud)

datafile <- here("data", "consultation", "email responses - all - DESENS.csv")
rawdata <- read.csv(datafile, header = TRUE, stringsAsFactors = FALSE)

colnames(rawdata) <- c("doc_id","subject","text", "category")

tidy_emails <- rawdata %>% 
                unnest_tokens(words, text) %>% 
                rename(word = words)

data("stop_words")

cleaned_emails <- tidy_emails %>% 
                  anti_join(stop_words) 

# most common words
cleaned_emails %>% count(word, sort = TRUE)

# we need to get rid of more common words later on


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


bing_word_counts %>%
  filter(n > 110) %>%
  mutate(n = ifelse(sentiment == "negative", -n, n)) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = sentiment)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ylab("Contribution to sentiment") +
  coord_flip()


library(reshape2)

tidy_emails %>%
  inner_join(bing) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("#F8766D", "#00BFC4"),
                   max.words = 100)

# https://github.com/trinker/sentimentr

library(sentimentr)
library(magrittr)

test <- rawdata$text %>% 
        get_sentences() %>% 
        sentiment()

test2 <- rawdata %>% 
          mutate(sentences = get_sentences(text)) %$% 
          sentiment_by(sentences, doc_id)

test2 %>% ggplot(aes(x = doc_id, y = ave_sentiment, fill = word_count)) +
          geom_bar(stat = "identity")

tidy_sentences <- rawdata %>% 
                  mutate(sentence = get_sentences(text)) %>% 
                  unnest(sentence) %>% 
                  group_by(doc_id) %>% 
                  mutate(sentenceid = row_number(doc_id)) %>% 
                  ungroup()

sentencesentiment <- tidy_sentences %>%
                      mutate(s1 = get_sentences(sentence)) %$% 
                      sentiment(s1)

sentencedata <- tidy_sentences %>% 
                bind_cols(sentencesentiment) %>% 
                select(-element_id, -sentence_id, sentence_id = sentenceid) 

sentencedata %>% ggplot(aes(x = sentence, y = sentiment, fill = word_count)) +
                  geom_bar(stat = "identity")

x <- sentencedata %>%
      group_by(sentence) %>% 
      summarise(count = n()) %>% 
      arrange(desc(count))
      

