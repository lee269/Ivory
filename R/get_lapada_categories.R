#'get_lapada_categories
#'
#'Function to scrape item data from the summary pages at lapada.org. Default is
#'to work with category pages, eg
#'https://lapada.org/art-and-antiques/books-maps/, but it will work with the
#'results of keyword searches
#'
#'@param baseurl The url of the page to start scraping. A category page, eg
#'  https://lapada.org/art-and-antiques/books-maps/, or the result of a search
#'  eg https://lapada.org/art-and-antiques/?search=ivory. If a search is used
#'  you need to set isSearch to TRUE
#'@param category Text to include as a category variable in the output. 
#'@param isSearch set to TRUE if your url is a search result
#'
#'@return A data frame of item data
#'@export
#'
#' @examples
get_lapada_categories <- function(baseurl, category = "Items", isSearch = FALSE){

    require(rvest)
    require(xml2)
    require(tm)
    require(stringr)

    # set up some objects to collect the outputs
    #pages <- 395
    ah_output <- list()
    item_output <- list()
    price_output <- list()
    output <- data.frame()
    
    # baseurl <- "https://lapada.org/art-and-antiques/?search=ivory"
    # baseurl <- "https://lapada.org/art-and-antiques/fine-art-sculpture/"
    # baseurl <- "https://lapada.org/art-and-antiques/"
    # baseurl <- "https://lapada.org/art-and-antiques/books-maps/"
    # selectors to collect data from pages
    dealer <- ".content div:nth-child(1)"
    item <- "strong"
    artist <- ".capitalise" #artist has missing values so not used yet
    price <- ".price"
    image <- "#frm-filter img"
    
    
    # Scrape base page to get total number of pages to cycle through. If there
    # are no pages to cycle through then just set pages = 1. Terrible kludge to
    # sort out nautical items - need a better way of getting the highest page
    # no.
    pages <-  baseurl %>% 
      read_html %>% 
      html_nodes(".paginator") %>% 
      html_text() %>% 
      stripWhitespace() %>% 
      str_trim() %>% 
      word(end = -2) %>% 
      word(-1) %>% 
      as.numeric()
      if (is.na(pages)) {pages <- 1}

    # if (baseurl == "https://lapada.org/art-and-antiques/nautical-maritime-antiques") {
    #   pages <- baseurl %>% 
    #     read_html %>% 
    #     html_nodes(".paginator li:nth-child(5) a") %>% 
    #     html_text()
    # } else {
    #   pages <- baseurl %>% 
    #     read_html %>% 
    #     html_nodes(".paginator li:nth-child(7) a") %>% 
    #     html_text()
    #   pages <- as.numeric(pages)
    #   if (is_empty(pages)) {pages <- 1}
    # }
    
    # Loop through each page and grab the data
    for (i in 1:pages) {
    
      # note use &pg= for paging through a search and ?pg= for paging through the
      # catalogue sections.
      pager <- "?pg="
      
      if (isSearch == TRUE) { pager <- "&pg="}
      
      pageurl <- paste(baseurl, pager, i, sep = "")
      html <- read_html(pageurl)  
    
      print(paste("processing page", i, "of", pages))
      
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
        data.frame(stringsAsFactors = FALSE) %>%
        select(url = 1) %>% 
        filter(!str_detect(url , "pg="))
      
      x <- data.frame(ah_list, item_list, price_list, image_list, url_list, stringsAsFactors = FALSE)
      output <- rbind(output, x)
    }
    
      colnames(output) <- c("dealer", "item", "price", "image", "url")
      output$category <- category
      output
      
}
      
