library(shiny)
library(leaflet)
library(sf)
library(RColorBrewer)
library(dplyr)
library(shinyjs)
library(readr)

offsite_species <- st_read("../data/offsite_species.shp") %>% 
  select(OPENING, ACTIVIT, Species, SEEDLOT, NUMBER_, AGE, REFEREN, BGC, area) 

offsite_species <- st_centroid(offsite_species) 
offsite_species <- st_transform(offsite_species, 4326)



bec_rsk <- st_read("../data/bec_rsk.shp")
bec_rsk <- st_transform(bec_rsk, 4326)



## creating a palette function to fill in map polygons (repeating section 3 material)
popn_bins <- unique(bec_rsk$ZONE)
pal <- colorFactor(
  brewer.pal(10, "Paired"), 
                domain = bec_rsk$zone)



## PERSISTENT DATA STORAGE #########################################################

## list columns
fields <- c("BGC", "opening_ID", "treatment_unit", "seedlot", "number_planted", "area_planted", "age", "last_assessment_date", "FD", "LW", "CW")

## reading in master project table
df <- read_csv("../data/offsite_records.csv", col_types = cols(BGC = col_character(),
                                                   opening_ID = col_integer(),
                                                   treatment_unit = col_integer(),
                                                   seedlot = col_integer(),
                                                   number_planted = col_integer(),
                                                   area_planted = col_double(),
                                                   age = col_integer(),
                                                   last_assessment_date = col_date(),
                                                   FD = col_logical(),
                                                   LW = col_logical(),
                                                   CW = col_logical()
                                                   )
               )

## updating the card form with new user entries and saving them in R environment
save_record <- function(dt) {
  dt <- as.data.frame(t(dt))
  # dt <- dt %>%
  #   gather("hosting", "value", -Status, -Project, -Deadline, -grep("^Deadline\\d", colnames(dt)), -Comments) %>%
  #   gather("ddl", "Indi_deadline", -Status, -Project, -Deadline, -Comments, -hosting, -value) %>%
  #   mutate(X1 = as.double(NA),
  #          Deadline = as_date(as.numeric(as.character(dt$Deadline))),
  #          Comment = as.character(NA),
  #          Completed = as.logical(NA))
  print(dt)
  # dt$Indi_deadline <- as_date(as.numeric(dt$Indi_deadline))

  if (!is.null(df)) {
    df <<- rbind(df, dt)
    df$X1 <- NULL # deletes original rowname containing NA
    write_csv(df, "../data/offsite_records.csv")
  } else {
    df <<- dt
  }
}
