library(rvest)
library(xml2)

# lapada1 <- read_html("https://lapada.org/art-and-antiques/?search=ivory")
# pg1 <- html_nodes(lapada1, ".price")
# pg1 <- unlist(as_list(pg1))

pages <- 8
ah_output <- list()
item_output <- list()
price_output <- list()


auctionhouse <- ".content div:nth-child(1)"
item <- "strong"
artist <- ".capitalise"
price <- ".price"


baseurl <- "https://lapada.org/art-and-antiques/?search=ivory"

for (i in 1:pages) {

  html <- read_html(paste(baseurl, "&pg=", i, sep = ""))  

  print(paste("processing page", i))
  
  pg <- html_nodes(html, css = auctionhouse)
  pg <- unlist(as_list(pg))
  ah_output <- append(ah_output, pg)

  pg <- html_nodes(html, css = item)
  pg <- unlist(as_list(pg))
  item_output <- append(item_output, pg)
  
  pg <- html_nodes(html, css = price)
  pg <- unlist(as_list(pg))
  price_output <- append(price_output, pg)
  
}

 ah_output <- unlist(ah_output)
 item_output <- unlist(item_output)
 price_output <- unlist(price_output)

 lapada <- as.data.frame(cbind(ah_output, item_output, price_output))
  colnames(lapada) <- c("auctionhouse", "item", "price")
