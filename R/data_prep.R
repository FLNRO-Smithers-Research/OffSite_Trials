library(sf)
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
silvi <- read_sf("../RESULTS/RSLT_FOREST_COVER_SILV_SVW/RSLT_FCSLV_polygon.shp")

silvi_rsk <- st_intersection(RSK, silvi)

## RESULTS layer for Skeena
write_sf(silvi_rsk , "../RESULTS_rsk.shp", driver = "ESRI Shapefile")




## READ IN PROCESSED RESULTS ################################################################
bec_rsk <- read_sf("data/bec_rsk.shp")
silvi_rsk_full <- read_sf("../RESULTS_rsk.shp")
speciesList = c("FD", "LW", "CW", "PY", "FDI", "FDC") 



## clip species
silvi_rsk <- silvi_rsk_full %>% 
  select(BGC_ZN_CD, matches("SPP([0-9]+)_CD"), ) %>% 
  gather(-BGC_ZN_CD, -geometry, key = "species_col", value = "Species") %>% 
  filter(Species %in% speciesList)
beepr::beep()

write_sf(silvi_rsk, "../filtered_RESULTS.shp")

silvi_rsk <- read_sf("../filtered_RESULTS.shp")

## joining RESULTS layer with BEC for BEC zones
silvi_bec <- st_intersection(st_buffer(silvi_rsk, 0), st_buffer(bec_rsk, 0))
beepr::beep()

write_sf(silvi_bec, "../silvi_bec_JOINED.shp")

## PLANT layer processing ###################################################################
planting <- read_sf("../PLANTING_SVW.shp") %>% 
  filter(SILV_TREE_ %in% speciesList) %>% 
  dplyr::select(ACTIVITY_T,
                OPENING_ID,
                MAP_LABEL,
                SILV_BASE_,
                SILV_TECHN,
                SILV_METHO,
                ATU_COMPLE,
                ACTUAL_TRE,
                SILV_TREE_,
                NUMBER_PLA,
                PLANTED_NO,
                SEEDLOT_NU)   

beepr::beep()
beepr::beep()

silv <- read_sf("../SILV_SVW.shp") %>%
  filter(S_SPECIES_ %in% speciesList | S_SPECIE_4 %in% speciesList | 
           S_SPECIE_8 %in% speciesList| S_SPECIE10 %in% speciesList |
           S_SPECIE12 %in% speciesList) %>% 
  dplyr::select(FOREST_COV,
                STOCKING_S,
                OPENING_ID,
                SILV_POL_1,
                SILV_POL_2,
                REFERENCE_,
                BGC_ZONE_C,
                BGC_SUBZON,
                BGC_VARIAN,
                BGC_PHASE,
                BEC_SITE_S,
                S_TOTAL_ST,
                S_TOTAL_WE,
                S_WELL_SPA,
                S_FREE_GRO,
                S_SPECIES_:S_SPECIE13,
                S_SILV_LAB)

beepr::beep()
beepr::beep()

write_sf(silv, "../SILV_PROCESSED.shp")
write_sf(planting, "../PLANT_PROCESSED.shp")

plant_silv <- st_join(planting, silv)

plant_silv$OPENING_ID.y <- NULL
names(plant_silv)[2] <- "OPENING_ID"

plant_silv <- plant_silv %>% 
  gather(-ACTIVITY_T, -OPENING_ID, -MAP_LABEL, -SILV_BASE_, -SILV_TECHN, -SILV_METHO, -ATU_COMPLE, -ACTUAL_TRE,
         -SILV_TREE_, -NUMBER_PLA, -PLANTED_NO, -SEEDLOT_NU, -FOREST_COV, -STOCKING_S, -SILV_POL_1, -SILV_POL_2,
         -REFERENCE_,-BGC_ZONE_C, -BGC_SUBZON, -BGC_VARIAN, -BGC_PHASE, -BEC_SITE_S, -S_TOTAL_ST, -S_TOTAL_WE, 
         -S_WELL_SPA, -S_FREE_GRO, -S_SILV_LAB, -geometry, key = "species_col", value = "Species") %>% 
  filter(Species %in% speciesList)
beepr::beep()


write_sf(st_buffer(plant_silv, 0), "../SILV_PLANT_JOIN.shp", delete_layer = TRUE)

## joining with reference and planting layer #################################################
speciesList = c("FD", "LW", "CW", "PY", "FDI", "FDC") 

silvi_bec <- read_sf("../silvi_bec_JOINED.shp") %>% 
  rename("BGC" = "MAP_LAB") 

## planting layer
plant_silv <- read_sf("../SILV_PLANT_JOIN.shp")

silvi_plant_bec <- st_join(silvi_bec, plant_silv)

silvi_plant_bec <- silvi_plant_bec %>% 
  filter(!is.na(BGC) & !is.na(Species.x)) %>% 
  mutate(Species.x = case_when(Species.x == "FDI"  ~ "FD",
                               Species.x == "FDC" ~ "FD",
                               Species.x == "CW" ~ "CW",
                               Species.x == "LW" ~ "LW"),
         Species.y = case_when(Species.x == "FDI"  ~ "FD",
                               Species.x == "CW" ~ "CW",
                               Species.x == "LW" ~ "LW")
  )

ref <- read_csv("data/ReferenceGuide2019_Onsite.csv") %>% 
  mutate(Species=toupper(Species)) %>% # convert spp to uppercase to match RESULTS
  filter(Species %in% speciesList) 



## anti join for offsite species, first by BGC then Species
offsite_species <- silvi_plant_bec %>% 
  anti_join(., ref, by=c("BGC", "Species.x" = "Species")) 

offsite_species <- offsite_species %>% 
  rename("Species" = "Species.x")

write_sf(offsite_species, "data/offsite_species.shp")


## stats summary ##############################################################################
## using st_area to get area by species, but before that, filter for unique

offsite_species <- read_sf("data/offsite_species.shp")

offsite_species$area <- as.numeric(st_area(offsite_species))

## area sum, unit m^2
offsite_sum <- as_tibble(offsite_species) %>% 
  select(-geometry) %>% 
  group_by(Species) %>% 
  dplyr::summarise(area = sum(area))

