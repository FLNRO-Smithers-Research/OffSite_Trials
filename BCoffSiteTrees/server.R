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
                       overlayGroups = c("BGC Zones", "Offsite Species")) %>%
      addPolygons(data = bec_rsk, fillColor = ~pal(ZONE), 
                  color = "transparent", 
                  fillOpacity = .7,
                  group = "BGC Zones") %>% 
      addCircles(data = offsite_species, 
                 radius = ~FEAT_AR/1000000,
                 fillColor = "yellow", 
                 fillOpacity = .8, 
                 color = "black", 
                 weight = 1.5,
                 group = "Offsite Species",
                 popup = paste0("<b>", offsite_species$Species, "</b>", "<br>", 
                                "BGC: ", offsite_species$BGC_LAB, "<br>")) %>% 
      addLegend(pal = pal, 
                bec_rsk$ZONE, 
                position = "bottomleft", 
                opacity = 0.5,
                title = "BGC Zones",
                group = "BGC Zones") 
  })
  
}
