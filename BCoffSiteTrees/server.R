#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/

#
library(shiny)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
  output$offsite_map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%
      addLayersControl(baseGroups = c("Default", "Satellite"), 
                       options = layersControlOptions(collapsed = FALSE),
                       overlayGroups = c("CW", "FD", "LW", "BGC Zones")) %>% 
    addPolygons(data = bec_rsk, fillColor = ~pal(ZONE), 
                color = "transparent", 
                fillOpacity = .7,
                group = "BGC Zones") %>% 
      addCircles(data = offsite_species[offsite_species$Species == "CW" ,], 
                 group = "CW",
                 # radius = ~FEAT_AR/1000000,
                 radius = 5000,
                 fillColor = "yellow",
                 # fillColor = "#1b9e77",
                 fillOpacity = .2, 
                 color = "",
                 weight = 1.5,
                 popup = paste0("<b>Opening ID: </b>", offsite_species$OPENING, "<br>", 
                                "<b>Activity Treatment Unit: </b>", offsite_species$ACTIVIT, "<br>", 
                                "<bSpecies: </b>", offsite_species$Species, "<br>",
                                "<b>Seedlot: </b>", offsite_species$SEEDLOT, "<br>", 
                                "<b>Number Planted: </b>", offsite_species$NUMBER_, "<br>", 
                                "<b>Age: </b>", offsite_species$AGE, "<br>", 
                                "<b>Area Planted: </b>", offsite_species$FEAT_AR, "<br>", 
                                "<b>Last Assessment Date: </b>", offsite_species$REFEREN, "<br>", 
                                "<b>BGC: </b>", offsite_species$BGC, "<br>",
                                "")) %>% 
      addCircles(data = offsite_species[offsite_species$Species == "FD" ,], 
                 group = "FD",
                 # radius = ~FEAT_AR/1000000,
                 fillColor = "#e41a1c",
                 radius = 5000,
                 # fillColor = "#7570b3",
                 fillOpacity = .2, 
                 color = "",
                 weight = 1.5,
                 popup = paste0("<b>Opening ID: </b>", offsite_species$OPENING, "<br>", 
                                "<b>Activity Treatment Unit: </b>", offsite_species$ACTIVIT, "<br>", 
                                "<bSpecies: </b>", offsite_species$Species, "<br>",
                                "<b>Seedlot: </b>", offsite_species$SEEDLOT, "<br>", 
                                "<b>Number Planted: </b>", offsite_species$NUMBER_, "<br>", 
                                "<b>Age: </b>", offsite_species$AGE, "<br>", 
                                "<b>Area Planted: </b>", offsite_species$FEAT_AR, "<br>", 
                                "<b>Last Assessment Date: </b>", offsite_species$REFEREN, "<br>", 
                                "<b>BGC: </b>", offsite_species$BGC, "<br>",
                                "")) %>% 
      addCircles(data = offsite_species[offsite_species$Species == "LW" ,], 
                 group = "LW",
                 # radius = ~FEAT_AR/1000000,
                 fillColor = "#377eb8",
                 radius = 5000,
                 # fillColor = "#d95f02",
                 fillOpacity = .2, 
                 color = "",
                 weight = 1.5,
                 popup = paste0("<b>Opening ID: </b>", offsite_species$OPENING, "<br>", 
                                "<b>Activity Treatment Unit: </b>", offsite_species$ACTIVIT, "<br>", 
                                "<bSpecies: </b>", offsite_species$Species, "<br>",
                                "<b>Seedlot: </b>", offsite_species$SEEDLOT, "<br>", 
                                "<b>Number Planted: </b>", offsite_species$NUMBER_, "<br>", 
                                "<b>Age: </b>", offsite_species$AGE, "<br>", 
                                "<b>Area Planted: </b>", offsite_species$FEAT_AR, " (ha)<br>", 
                                "<b>Last Assessment Date: </b>", offsite_species$REFEREN, "<br>", 
                                "<b>BGC: </b>", offsite_species$BGC, "<br>",
                                "")) %>%
      addLegend(pal = pal, 
                bec_rsk$ZONE, 
                position = "bottomleft", 
                opacity = 0.5,
                title = "BGC Zones",
                group = "BGC Zones") 
  })
  
}
