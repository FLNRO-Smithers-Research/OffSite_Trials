library(sf)
# library(bcmaps)
library(readr)
library(dplyr)
library(rmapshaper)
library(tidyr)

## bcmaps query for beczone layer downloaded from BC Data Catalogue
bec <- read_sf("../BEC/BEC_BIOGEOCLIMATIC_POLY/BEC_POLY_polygon.shp")  # from file, identical with bcmaps::bec()

## simplification doesn't work at this step for entire BC Bec
# bec <- ms_simplify(bec)

## RESULTS layer ################################################################
silvi <- read_sf("../RESULTS/RSLT_FOREST_COVER_SILV_SVW/RSLT_FCSLV_polygon.shp")

## joining beczone with rsk shape
RSK <- read_sf("../RSK.shp")
bec_rsk_lg <- st_intersection(RSK, st_buffer(bec, 0))

## working example, retaining 5% of the original details
bec_rsk <- ms_simplify(bec_rsk_lg)

## read in 
bec_rsk <- read_sf("../bec_rsk.shp")

# silvi_rsk <- st_intersection(RSK, silvi)
# 
# write_sf(silvi_rsk , "../RESULTS_rsk.shp", driver = "ESRI Shapefile")

silvi_rsk_full <- read_sf("../RESULTS_rsk.shp")
speciesList = c("FD", "LW", "CW", "PY", "FDI", "FDC") 

## clip species
silvi_rsk <- silvi_rsk_full %>% 
  select(BGC_ZN_CD, matches("SPP([0-9]+)_CD")) %>% 
  gather(-BGC_ZN_CD, -geometry, key = "species_col", value = "Species") %>% 
  filter(Species %in% speciesList)


## filter funciton before gathering
# filter(S_SPP1_CD %in% speciesList | S_SPP2_CD  %in% speciesList | S_SPP3_CD  %in% speciesList | S_SPP4_CD  %in% speciesList |
#        S_SPP5_CD %in% speciesList | S1_SPP1_CD %in% speciesList | S1_SPP2_CD %in% speciesList | S1_SPP3_CD %in% speciesList |
#        S1_SPP4_CD %in% speciesList | S1_SPP5_CD %in% speciesList | S2_SPP1_CD %in% speciesList | S2_SPP2_CD %in% speciesList |
#        S2_SPP3_CD %in% speciesList | S2_SPP4_CD %in% speciesList | S2_SPP5_CD %in% speciesList | S3_SPP1_CD %in% speciesList |
#        S3_SPP2_CD %in% speciesList | S3_SPP3_CD %in% speciesList | S3_SPP4_CD %in% speciesList | S3_SPP5_CD %in% speciesList | 
#        S4_SPP1_CD %in% speciesList | S4_SPP2_CD %in% speciesList | S4_SPP3_CD %in% speciesList | S4_SPP4_CD %in% speciesList |
#       S4_SPP5_CD %in% speciesList)

## silvi_bec_long <- gather(silvi_bec, -BGC_ZN_CD, -geometry, key = "species_col", value = "Species")

write_sf(silvi_rsk, "../filtered_RESULTS.shp")

## joining RESULTS layer with BEC for BEC zones
silvi_bec <- st_intersection(st_buffer(silvi_rsk, 0), st_buffer(bec_rsk, 0))
beepr::beep()

write_sf(silvi_bec, "../silvi_bec_JOINED.shp")

## reference layer

ref <- read_csv("data/ReferenceGuide2019_Onsite.csv") %>% 
  mutate(Species=toupper(Species)) %>% # convert spp to uppercase to match RESULTS
  filter(Species %in% speciesList) 



offsite_species <- silvi_bec %>% 
  group_by(BGC_ZN_CD) %>% 
  anti_join(., ref, by=c("Species" = "Species"))


write_sf(offsite_species, "../offsite_species.shp")
beepr::beep()


## stats summary
spp_sum <- as_tibble(spp_offsite) %>% 
  group_by(BGC_LABEL, ) %>% 
  summarize(Num.openings=n(), # Summarize number of openings planted with Fd
            # Area.planted=sum(AREA_SQM, na.rm = TRUE), # summarize area planted with Fd
            # Total.WS.trees=sum(WELL_SPACED_HA,na.rm=T)
  )  # summarize total Fd well spaced
# filter(BGC!="NANA") # remove NA BGC units

## using st_area to get area by species, but before that, filter for unique

