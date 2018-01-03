# Ivory

Adventures in webscraping. I've never done this before. The goal is to scrape the catalogue from the LAPADA website www.lapada.org, before seeing what analysis we can do around ivory objects available for sale.

## Procedure

### Make catalogue dataset

First we make a dataset containing the summary details available from the category listing pages (such as https://lapada.org/art-and-antiques/silver/). The code to do this is in make_lapada_catalogue.R. Thhis code draws upon the get_lapada_categories function, and also represents my firs ever use of purrr functions - cool.

If we run this across all categories we essentially get a complete catalogue listing. But there is more detail in the individual item pages (such as https://lapada.org/art-and-antiques/antique-pair-of-edwardian-sterling-silver-candlesticks-1907/). So the next step is...

### Capture Item data

The catalogue dataset includes urls to individual items. So next we run the code in combine_lapada_data.R. This draws upon the get_lapada_items function, and loops through the item urls picking up the extra attributes available for each item. These are then saved to separate catecory csvs

### Merge catalogue and item data

Still to do...