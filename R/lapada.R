library(rvest)
library(xml2)
library(here)

# lapada1 <- read_html("https://lapada.org/art-and-antiques/fine-art-sculpture/?pg=1")
# pg1 <- html_nodes(lapada1, "#frm-filter img")
# pg1 <- html_attr(pg1, "src")

pages <- 395
ah_output <- list()
item_output <- list()
price_output <- list()
output <- data.frame()

# baseurl <- "https://lapada.org/art-and-antiques/?search=ivory"
# baseurl <- "https://lapada.org/art-and-antiques/fine-art-sculpture/"
 baseurl <- "https://lapada.org/art-and-antiques/"
dealer <- ".content div:nth-child(1)"
item <- "strong"
artist <- ".capitalise" #artist has missing values so not used yet
price <- ".price"
image <- "#frm-filter img"



for (i in 1:pages) {

  # note use &pg= for paging through a search and ?pg= for paging through the
  # catalogue sections.
  pageurl <- paste(baseurl, "?pg=", i, sep = "")
  html <- read_html(pageurl)  

  print(paste("processing page", i))
  
  ah_list <- html %>% html_nodes(dealer) %>% html_text()
  item_list <- html %>% html_nodes(item) %>% html_text()
  price_list <- html %>% html_nodes(price) %>% html_text()
  # image fails because it finds more than 40 images on the page
  # There are two arrow images that I cant find
  # so Ill just delete them
  image_list <- html %>% html_nodes(image) %>% html_attr("src")
  #  remove the first 2 elements (arrow image refs)
  image_list <- image_list[-c(1,2)]
  # pull the url of the individual item pages out of the table page
  # maybe we can scrape the item pages later
  url_list <- html %>% 
    html_nodes(".item a") %>% 
    html_attr("href") %>% 
    unique() %>% 
    data.frame() %>% 
    filter(. != gsub(pattern = "https", replacement = "http", x = pageurl))
  
  
  x <- data.frame(ah_list, item_list, price_list, image_list, url_list)
  output <- rbind(output, x)
}

  colnames(output) <- c("dealer", "item", "price", "image", "url")
  
       write.csv(output, here("data", "lapadacatalogue.csv"))
