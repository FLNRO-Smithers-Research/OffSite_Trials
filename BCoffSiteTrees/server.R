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
   
  ## MAP TAB ##############################################################
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
                 radius = 500,
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
                                "<b>Area Planted: </b>", offsite_species$area, "<br>", 
                                "<b>Last Assessment Date: </b>", offsite_species$REFEREN, "<br>", 
                                "<b>BGC: </b>", offsite_species$BGC, "<br>",
                                "")) %>% 
      addCircles(data = offsite_species[offsite_species$Species == "FD" ,], 
                 group = "FD",
                 # radius = ~FEAT_AR/1000000,
                 fillColor = "#e41a1c",
                 radius = 500,
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
                                "<b>Area Planted: </b>", offsite_species$area, "<br>", 
                                "<b>Last Assessment Date: </b>", offsite_species$REFEREN, "<br>", 
                                "<b>BGC: </b>", offsite_species$BGC, "<br>",
                                "")) %>% 
      addCircles(data = offsite_species[offsite_species$Species == "LW" ,], 
                 group = "LW",
                 # radius = ~FEAT_AR/1000000,
                 fillColor = "#377eb8",
                 radius = 500,
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
                                "<b>Area Planted: </b>", offsite_species$area, " (ha)<br>", 
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
  
  
  ## NEW RECORD TAB #######################################
  ## tab 1 creating a new card and save
  record_data <- reactive({
    dt <- sapply(fields, function(x) input[[x]]) # tabulates and saves user inputs
    dt
  })
  
  ## check box in datatable
  shinyInput <- function(FUN, len, id, ...) {
    inputs <- character(len)
    for (i in seq_len(len)) {
      inputs[i] <- as.character(FUN(paste0(id, i), label = NULL, ...))
    }
    inputs
  }
  
  ## obtaining checkbox value
  shinyValue = function(id, len) { 
    unlist(lapply(seq_len(len), function(i) { 
      value = input[[paste0(id, i)]] 
      if (is.null(value)) FALSE else value 
    })) 
  } 
  
  
  ## form ####
  observeEvent(
    input$submit_form, {
      save_record(record_data())
      reset("form")
    })
  
}
