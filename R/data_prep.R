library(sf)
# library(bcmaps)
library(readr)
library(dplyr)
library(rmapshaper)
library(tidyr)

## BEC from BC Data Catalogue ############################################
bec <- read_sf("../BEC/BEC_BIOGEOCLIMATIC_POLY/BEC_POLY_polygon.shp")  # from file, identical with bcmaps::bec()
bec_rsk <- read_sf("../bec_rsk.shp")

## joining beczone with rsk shape
RSK <- read_sf("../RSK.shp")
bec_rsk_lg <- st_intersection(RSK, st_buffer(bec, 0))

## working example, retaining 5% of the original details
bec_rsk <- ms_simplify(bec_rsk_lg)

## simplification doesn't work at this step for entire BC Bec
# bec <- ms_simplify(bec)

## RESULTS layer processing ################################################################
## read in 
bec_rsk <- read_sf("../bec_rsk.shp")

silvi <- read_sf("../RESULTS/RSLT_FOREST_COVER_SILV_SVW/RSLT_FCSLV_polygon.shp")

silvi_rsk <- st_intersection(RSK, silvi)

## RESULTS layer for Skeena
write_sf(silvi_rsk , "../RESULTS_rsk.shp", driver = "ESRI Shapefile")


## READ IN PROCESSED RESULTS ################################################################

silvi_rsk_full <- read_sf("../RESULTS_rsk.shp")
speciesList = c("FD", "LW", "CW", "PY", "FDI", "FDC") 

## clip species
silvi_rsk <- silvi_rsk_full %>% 
  select(BGC_ZN_CD, matches("SPP([0-9]+)_CD")) %>% 
  gather(-BGC_ZN_CD, -geometry, key = "species_col", value = "Species") %>% 
  filter(Species %in% speciesList)
beepr::beep()

write_sf(silvi_rsk, "../filtered_RESULTS.shp")

silvi_rsk <- read_sf("../filtered_RESULTS.shp")

## joining RESULTS layer with BEC for BEC zones
silvi_bec <- st_intersection(st_buffer(silvi_rsk, 0), st_buffer(bec_rsk, 0))
beepr::beep()

write_sf(silvi_bec, "../silvi_bec_JOINED.shp")
## joining with reference layer ################################################
speciesList = c("FD", "LW", "CW", "PY", "FDI", "FDC") 

silvi_bec <- read_sf("../silvi_bec_JOINED.shp") %>% 
rename("BGC" = "BGC_ZN_") 

silvi_bec <- silvi_bec %>% 
  filter(!is.na(BGC) & !is.na(Species)) %>% 
  mutate(Species = case_when(Species == "FDI"  ~ "FD",
                             Species == "FDC" ~ "FD",
                             Species == "CW" ~ "CW",
                             Species == "LW" ~ "LW"),
         BGC = case_when(BGC == "CWH" ~ "CWH",
                         BGC == "SBS" ~ "SBS",
                         BGC == "ESSF" ~ "ESS",
                         BGC == "ICH" ~ "ICH"))

ref <- read_csv("data/ReferenceGuide2019_Onsite.csv") %>% 
  mutate(Species=toupper(Species)) %>% # convert spp to uppercase to match RESULTS
  filter(Species %in% speciesList) 

## reformat BGC code according to silvi_bec format
ref$BGC <- substr(ref$BGC, 1, 3)

ref <- ref %>% 
  filter(BGC == "CWH" | BGC == "SBS" | BGC == "ESS" | BGC == "ICH")

offsite_species <- silvi_bec %>% 
  anti_join(., ref, by=c("BGC", "Species")) 

write_sf(offsite_species, "data/offsite_species.shp")


## stats summary ##################################################################
## using st_area to get area by species, but before that, filter for unique

offsite_species <- read_sf("data/offsite_species.shp")

offsite_species$area <- as.numeric(st_area(offsite_species))

## area sum, unit m^2
offsite_sum <- as_tibble(offsite_species) %>% 
  select(-geometry) %>% 
  group_by(Species) %>% 
  dplyr::summarise(area = sum(area))


