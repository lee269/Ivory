library(rvest)
library(xml2)
library(here)

# lapada1 <- read_html("https://lapada.org/art-and-antiques/fine-art-sculpture/?pg=1")
# pg1 <- html_nodes(lapada1, "#frm-filter img")
# pg1 <- html_attr(pg1, "src")

pages <- 394
ah_output <- list()
item_output <- list()
price_output <- list()
output <- data.frame()

# baseurl <- "https://lapada.org/art-and-antiques/?search=ivory"
# baseurl <- "https://lapada.org/art-and-antiques/fine-art-sculpture/"
 baseurl <- "https://lapada.org/art-and-antiques/"
auctionhouse <- ".content div:nth-child(1)"
item <- "strong"
artist <- ".capitalise" #artist has missing values so not used yet
price <- ".price"
image <- "#frm-filter img"



for (i in 1:pages) {

  # note use &pg= for paging through a search and ?pg= for paging through the
  # catalogue sections.
  html <- read_html(paste(baseurl, "?pg=", i, sep = ""))  

  print(paste("processing page", i))
  
  ah_list <- html %>% html_nodes(auctionhouse) %>% html_text()
  item_list <- html %>% html_nodes(item) %>% html_text()
  price_list <- html %>% html_nodes(price) %>% html_text()
  # image fails because it finds more than 40 images on the page
  # There are two arrow images that I cant find
  # so Ill just delete them
  image_list <- html %>% html_nodes(image) %>% html_attr("src")
  #  remove the first 2 elements (arrow image refs)
  image_list <- image_list[-c(1,2)]
  
  x <- data.frame(ah_list, item_list, price_list, image_list)
  output <- rbind(output, x)
}

  colnames(output) <- c("auctionhouse", "item", "price", "image")
  
     # write.csv(output, here("data", "lapadacatalogue.csv"))
