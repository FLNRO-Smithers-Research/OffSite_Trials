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
bec_rsk <- st_intersection(RSK, st_buffer(bec, 0))

## working example, retaining 5% of the original details
bec_rsk <- ms_simplify(bec_rsk)

## write_sf(bec_rsk, "../bcmaps_bec_rsk.shp", driver = "ESRI Shapefile")

## reference layer
ref <- read_csv("data/ReferenceGuide2019_Onsite.csv")

bgc_join <- left_join(bec_rsk[, c("MAP_LABEL", "FEAT_AREA", "ZONE_NAME")], 
                      ref[, c("BGC", "SS_NoSpace", "Species")], 
                      by = c("MAP_LABEL" = "BGC"))
class(bgc_join) # sf, tbl


## fix geometry and write to file
write_sf(bgc_join, "data/bgc_bec_join.shp")

## will try the anti_join tonight
# silvi_bec <- anti_join(as_tibble(silvi), as_tibble(bec_rsk),
#                        by = c("BGC_SUBZON" = "SUBZONE"))
                       
