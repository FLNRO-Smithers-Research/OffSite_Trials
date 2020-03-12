library(offSiteTrees)
library(sf)
library(dplyr)
library(lwgeom)

## code to process and get clipped shapes ready for RSK region from manually downloaded datasets from 
## BC Data Catalogue

silvi_full <- read_sf("../silv-RSK.shp")

bec_rsk <- read_sf("../RSK_bec.shp")
bec <- read_sf("../BEC/BEC_BIOGEOCLIMATIC_POLY/BEC_POLY_polygon.shp") 

sppList=c("CW", "LW", "FD")
silvi <- silvi_full %>% 
  # filter(!is.na(BGC_ZONE_C)) %>%  # take away NA subzones in RESULTS dataframe
  filter(S_SPECIES_ %in% sppList |
           S_SPECIE_4 %in% sppList |
           S_SPECIE_8 %in% sppList |
           S1_SPECIES %in% sppList |
           S1_SPECI_4 %in% sppList |
           S1_SPECI_8 %in% sppList |
           S2_SPECIES	%in% sppList |
           S2_SPECI_4	%in% sppList |
           S2_SPECI_8	%in% sppList |
           S3_SPECIES %in% sppList |
           S3_SPECI_4 %in% sppList |
           S3_SPECI_8 %in% sppList|
           S4_SPECIES %in% sppList |
           S4_SPECI_4 %in% sppList |
           S4_SPECI_8 %in% sppList) 

silvi_bec <- anti_join(as_tibble(silvi), as_tibble(bec_rsk),
                       by = c("BGC_SUBZON" = "SUBZONE"))
                       

## outputs
write_sf(silvi, "../species_of_interest-RESULTS.shp")
write_sf(silvi_bec, "../joined_BEC_RESULTS.shp")

## OLD DATA PREP
## load shapefiles
# rsk <- read_sf("../BEC/ADM_NR_REGIONS_SP/ADM_NR_REG_polygon.shp") %>% 
#   filter(ORG_UNIT == "RSK") 
# 
# rsk <- st_make_valid(rsk)
# 
# 
# st_write(rsk, "../rsk-boundary.shp", delete_dsn = TRUE)
# 
# stbec <- read_sf("../BEC/BEC_BIOGEOCLIMATIC_POLY/BEC_POLY_polygon.shp") 
# 
# silvi_full <- read_sf("../RSLT_FOREST_COVER_SILV_SVW/RSLT_FCSLV_polygon.shp")
# 
# ## spatial join RESULTS to BEC data
# bec_silvi <- st_intersection(bec_rsk[, c("ZONE", "SUBZONE", "ZONE_NAME", "MAP_LABEL", "geometry")], 
#                              silvi_full[, c("PLY_AR", "S1_TWS_HA",
#                                        "S1_SPP1_CD", "S1_SPP2_CD", "S1_SPP3_CD", "S1_SPP4_CD", "S1_SPP5_CD", "geometry")])
# st_write(bec_silvi, "../joined_bec_results.shp")
# 
# 
# ## species of interest in RESULTS dataframe - offsite ANTI join
# sppList=c("CW", "LW", "FD")
# silvi <- silvi_full %>% 
#   filter(!is.na(BGC_SZN_CD)) %>%  # take away NA subzones in RESULTS dataframe
#   filter(S1_SPP1_CD	 %in% sppList|
#            S1_SPP2_CD	%in% sppList|
#            S1_SPP3_CD %in% sppList|
#            S1_SPP4_CD %in% sppList|
#            S1_SPP5_CD %in% sppList) 
# 
# 
# ## filter in bec_rsk where the habitats shouldn't be 
# ## ie join where silvi$BGC_SZN_CD != bec_rsk$SUBZONE to get offsite trees of CW, LW and FD species.
#  
# joined_BEC_RESULTS <- anti_join(as_tibble(silvi), as_tibble(bec_rsk), by = c("BGC_SZN_CD" = "SUBZONE"))
# 
# ## turn back to geo dataframe
# joined_offsite<- st_as_sf(joined_BEC_RESULTS)
# st_crs(joined_offsite) <- st_crs(silvi)
# ## output
# st_write(joined_offsite, "../joined_offsite.shp", delete_dsn = TRUE)
# 
# ## clip BEC zone with RSK shape
# # bec_rsk <- st_intersection(st_buffer(bec, 0), rsk)
# 
# 
# # spp_offsite<-
# #   cfrgPG %>%
# #   mutate(Spp=toupper(Spp)) %>% # convert spp to uppercase to match RESULTS
# #   filter(Spp%in%"FD") %>%   # filter for species of interest
# #   anti_join(x,.,by=c("BGC"="ZoneSubzone")) 

