library(shiny)
library(leaflet)
library(sf)
library(RColorBrewer)
library(dplyr)


offsite_species <- st_read("../data/offsite_species.shp") %>% 
  select(OPENING, ACTIVIT, Species, SEEDLOT, NUMBER_, AGE, REFEREN, BGC, FEAT_AR) 

offsite_species <- st_centroid(offsite_species) 
offsite_species <- st_transform(offsite_species, 4326)



bec_rsk <- st_read("../data/bec_rsk.shp")
bec_rsk <- st_transform(bec_rsk, 4326)



## creating a palette function to fill in map polygons (repeating section 3 material)
popn_bins <- unique(bec_rsk$ZONE)
pal <- colorFactor(
  brewer.pal(10, "Paired"), 
                domain = bec_rsk$zone)
