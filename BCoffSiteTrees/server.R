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
  ## REACTIVE DATA ######################################
  ## background polygon BGC layer
   bgcData <- reactive({
    bgc <- input$bgc
    bec_rsk %>% 
    filter(ZONE %in% bgc)
  })
  
  ## point layer showing offsite species
  speciesData <- reactive({
    species <- input$species
    year <- as.numeric(input$year)
    
  
    
    ## include NA assessment dates
    if (isTRUE(input$year_NA)) {
      speciesData <- offsite_species %>%
        filter(
          Species %in% species &
            (is.na(REFEREN) |
               (REFEREN >= input$year[1] &
                  REFEREN <= input$year[2]))
        )
    ## don't include NA assessment dates
    } else {
      ## slider input
      speciesData <- offsite_species %>%
        filter(
                Species %in% species &
                REFEREN >= input$year[1] &
                REFEREN <= input$year[2]
                )
    }
    
    speciesData
  })
  
  
  
  
  ## MAP TAB ##############################################################
  output$offsite_map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%
      addLayersControl(baseGroups = c("Default", "Satellite"), 
                       options = layersControlOptions(collapsed = FALSE)) %>% 
      setView(lng = -128, lat = 56, zoom = 5.5) %>% 
      addLegend(pal = pal, 
                bec_rsk$ZONE, 
                position = "bottomleft", 
                opacity = 0.5,
                title = "BGC Zones",
                group = "BGC Zones") 
  }) 

  observe({
    
    ## attempt to speed up processing time
    # isolate(
    # leafletProxy("offsite_map") %>%
    #   clearShapes() %>%
    #   addPolygons(data = bgcData(), fillColor = ~pal(ZONE),
    #               color = "transparent",
    #               fillOpacity = .6)
    # 
    # )
    
    leafletProxy("offsite_map") %>%
      clearShapes() %>% 
      addPolygons(data = bgcData(), fillColor = ~pal(ZONE),
                                    color = "transparent",
                                    fillOpacity = .6) %>% 
      addCircles(data = speciesData(),
                 # radius = ~area*100,
                 radius = 500,
                 fillColor = ~species_pal(Species),
                 fillOpacity = 1,
                 color = "",
                 weight = .2,
                 popup = paste0("<b>Opening ID: </b>", speciesData()$OPENING, "<br>",
                                "<b>Activity Treatment Unit: </b>", speciesData()$ACTIVIT, "<br>",
                                "<b>Species: </b>", speciesData()$Species, "<br>",
                                "<b>Seedlot: </b>", speciesData()$SEEDLOT, "<br>",
                                "<b>Number Planted: </b>", speciesData()$NUMBER_, "<br>",
                                "<b>Age: </b>", speciesData()$AGE, "<br>",
                                "<b>Area Planted: </b>", speciesData()$area, "<br>",
                                "<b>Last Assessment Date: </b>", speciesData()$REFEREN, "<br>",
                                "<b>BGC: </b>", speciesData()$BGC, "<br>",
                                ""))
  })
  
  
  ## part of speed-up attempt
  # observeEvent(input$bgc, {
  #   leafletProxy("offsite_map") %>%
  #       clearShapes() %>%
  #       addPolygons(data = bgcData(), fillColor = ~pal(ZONE),
  #                   color = "transparent",
  #                   fillOpacity = .6) %>% 
  #     addCircles(data = speciesData(),
  #                # radius = ~area*100,
  #                radius = 500,
  #                fillColor = ~species_pal(Species),
  #                fillOpacity = 1,
  #                color = "",
  #                weight = .2,
  #                popup = paste0("<b>Opening ID: </b>", speciesData()$OPENING, "<br>",
  #                               "<b>Activity Treatment Unit: </b>", speciesData()$ACTIVIT, "<br>",
  #                               "<b>Species: </b>", speciesData()$Species, "<br>",
  #                               "<b>Seedlot: </b>", speciesData()$SEEDLOT, "<br>",
  #                               "<b>Number Planted: </b>", speciesData()$NUMBER_, "<br>",
  #                               "<b>Age: </b>", speciesData()$AGE, "<br>",
  #                               "<b>Area Planted: </b>", speciesData()$area, "<br>",
  #                               "<b>Last Assessment Date: </b>", speciesData()$REFEREN, "<br>",
  #                               "<b>BGC: </b>", speciesData()$BGC, "<br>",
  #                               ""))
  # 
  # })
  
  
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
