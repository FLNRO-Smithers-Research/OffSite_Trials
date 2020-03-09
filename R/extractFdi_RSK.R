# Extract RESULTs data

library(bcdata)
library(sf)

# Select region(s) of interest
regionCode=toupper(c("RSK")) #RSK = Skeena

# Select species of interest
sppList=c("FD","FDI","FDC")

region<-
  bcdata::bcdc_query_geodata("natural-resource-nr-regions") %>% #query region
  bcdata::filter(ORG_UNIT%in%regionCode) %>% # for region(s) of interest
  bcdata::collect() %>% # collect
  sf::st_union() # combine polygons into single

# Search for RESULTS databases
bcdc_search("RESULTS silviculture")

# Planting data
rskFDI.Plant<-
  bcdc_query_geodata("3666c26a-32d8-43e4-b8ad-59a315c7d3ce") %>%
  dplyr::filter(INTERSECTS(region)) %>% 
  filter(SILV_TREE_SPECIES_CODE %in% sppList) %>% 
  collect()

# Silviculture data
# Show polygons where forest cover lists Douglas-fir
rskFDI.silv<-
  bcdata::bcdc_query_geodata("results-forest-cover-silviculture") %>%
  dplyr::filter(bcdata::INTERSECTS(region)) %>%
  dplyr::filter(S_SPECIES_CODE_1%in%sppList|
                  S_SPECIES_CODE_2%in%sppList|
                  S_SPECIES_CODE_3%in%sppList|
                  S_SPECIES_CODE_4%in%sppList|
                  S_SPECIES_CODE_5%in%sppList) %>%
  collect()


