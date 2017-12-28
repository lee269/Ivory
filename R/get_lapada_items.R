#' get_lapada_items
#' 
#' Given a set of urls for lapada item pages, pull out full descriptions and
#' details from the 'object classitication' section of the page. It takes about
#' 18 minutes to harvest 1000 items, so best to run in chunks probably
#'
#' @param urls A list of lapada urls to scrape
#'
#' @return A data frame of scraped data.
#' @export
#'
#' @examples
get_lapada_items <- function(urls) {
    require(rvest)
    require(xml2)
    require(dplyr)
    require(purrr)
    require(stringr)
    require(tidytext)
    require(tm)
    require(tidyr)
    
    # selector for full description
    objectdescription <- ":nth-child(3) .page-content"
    
    # selector for classification section
    objclass <- ".classifications li"
    
    # read in the urls. This is using purrr's map function to apply a function
    # (read_html) across a list of urls (no for loops here!). I dont know how it
    # will cope with the full lapada list of 15,000 urls. Might need to break into
    # sections.
    html <- urls %>% map(read_html) 
    
    # Scrape the detailed object descriptions into a data frame. Note we also create
    # an id field which we will use for joining together the datasets later
    objdesc <- html %>% 
      map(html_nodes, objectdescription) %>% 
      map_df(map_df, ~list(var = .x %>%  html_text()), .id = "id") %>% 
      mutate(id = as.numeric(id)) %>% 
      rename(description = var)
    
    
    # parse the object classification section of the pages. We create an id field
    # for joining later. There are multiple attributes per id and they come in as
    # text such as 'country France'. We get rid of all the whitespace and crap, and
    # then make a new attribute variable containing the first word in the attribute
    # text, eg 'country'. Finally we spread the data frame out to wide form to make
    # a column for each attribute type.
    
    classifications <- html %>% 
      map(html_nodes, objclass) %>% 
      map_df(map_df, ~list(var = .x %>%  html_text()), .id = "id") %>% 
      mutate(id = as.numeric(id)) %>% 
      mutate(attribute = stripWhitespace(var)) %>% 
      mutate(attribute = str_trim(attribute)) %>% 
      mutate(attribute = word(attribute)) %>% 
      spread(key = attribute, value = var)
    
    urldf <- as.data.frame(urls)
    urldf <- data.table::transpose(urldf)
    urldf$id <- seq.int(nrow(urldf))
    colnames(urldf) <- c("url", "id")
    
    # urldf <- urldf %>% 
    #   mutate(id = as.numeric(id))   
    
    
    catalogue <- urldf %>%
            left_join(objdesc) %>% 
            left_join(classifications)

    catalogue
}


