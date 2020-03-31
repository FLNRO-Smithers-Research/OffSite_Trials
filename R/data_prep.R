library(sf)
# library(bcmaps)
library(readr)
library(dplyr)
library(rmapshaper)

## bcmaps query for beczone layer downloaded from BC Data Catalogue
bec <- read_sf("../BEC/BEC_BIOGEOCLIMATIC_POLY/BEC_POLY_polygon.shp")  # from file, identical with bcmaps::bec()

## simplification doesn't work at this step for entire BC Bec
# bec <- ms_simplify(bec)

## joining beczone with rsk shape
RSK <- read_sf("../RSK.shp")
bec_rsk_lg <- st_intersection(RSK, st_buffer(bec, 0))

## working example, retaining 5% of the original details
bec_rsk <- ms_simplify(bec_rsk_lg)

## write_sf(bec_rsk, "../bec_rsk.shp", driver = "ESRI Shapefile")

## reference layer
speciesList = c("FD", "LW", "CW", "PY") 

ref <- read_csv("data/ReferenceGuide2019_Onsite.csv") %>% 
  mutate(Species=toupper(Species)) %>% # convert spp to uppercase to match RESULTS
  filter(Species %in% speciesList)   # filter for species of interest
  


## join reference layer with rsk BEC, keep all records from ref
bgc_join <- left_join(ref[, c("BGC", "SS_NoSpace", "Species")], 
                      bec_rsk[, c("MAP_LABEL", "FEAT_AREA", "ZONE_NAME")], 
                      by = c("BGC" = "MAP_LABEL"))

## write to file
write_sf(bgc_join, "../bgc_bec_join.shp")

## anti join for offsite species
spp_offsite <- bgc_join %>% 
  anti_join(bec_rsk, by = c("BGC" = "MAP_LABEL"))

## turn back to sf
spp_offsite <- st_as_sf(spp_offsite)


## write output
write_sf(spp_offsite, "../spp_offsite.shp")



## anti join for offsite species
speciesList = c("FD", "LW", "CW", "PY") 
spp_offsite <-
  bgc_join %>%
  mutate(Species=toupper(Species)) %>% # convert spp to uppercase to match RESULTS
  filter(Species %in% speciesList) %>%   # filter for species of interest
  anti_join(bec_rsk, ., by=c("MAP_LABEL" = "BGC"))


## stats summary
spp_sum <- as_tibble(spp_offsite) %>% 
  group_by(BGC_LABEL, ) %>% 
  summarize(Num.openings=n(), # Summarize number of openings planted with Fd
            # Area.planted=sum(AREA_SQM, na.rm = TRUE), # summarize area planted with Fd
            # Total.WS.trees=sum(WELL_SPACED_HA,na.rm=T)
            )  # summarize total Fd well spaced
  # filter(BGC!="NANA") # remove NA BGC units

## using st_area to get area by species, but before that, filter for unique

