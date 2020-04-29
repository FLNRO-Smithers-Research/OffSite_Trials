#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#


library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("British Columbia Offsite Species"),
  
  fluidRow(
    column(9, offset = 1, br(),
           leafletOutput("offsite_map", height = "800px")
           ),
    column(3, br(),
           )
    )
  
)
