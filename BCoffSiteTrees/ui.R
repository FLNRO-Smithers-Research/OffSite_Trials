#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#

## user selection options

bgc <- levels(bec_rsk$ZONE)
species <- levels(offsite_species$Species)
year <- seq(min(offsite_species$REFEREN,na.rm = TRUE),
                      max(offsite_species$REFEREN,na.rm = TRUE), 1)


# Define UI for application that draws a histogram
ui <- navbarPage(useShinyjs(), 
  tabPanel(HTML("BC Offsite Species"),
          # Application title
          fluidRow(
            column(12, titlePanel("British Columbia Offsite Species")
                   )
          ),
          
          fluidRow(
            column(9, 
                   # offset = 1, 
                   br(),
                   leafletOutput("offsite_map", height = "600px")
                    ),
            ## user selections
            column(3, 
                   # offset = 1, 
                   br(),
                   selectizeInput("species", "Species", species, selected = unique(offsite_species$Species), multiple = TRUE),
                   checkboxGroupInput("bgc", "BGC", bgc, 
                                      # selected = unique(bec_rsk$ZONE)
                                      ),
                   sliderInput("year", "Planting Year",
                               min(offsite_species$REFEREN,na.rm = TRUE),
                               max(offsite_species$REFEREN,na.rm = TRUE),
                               value = c(min(offsite_species$REFEREN,na.rm = TRUE), max(offsite_species$REFEREN,na.rm = TRUE)),
                               sep = ""),
                   checkboxInput("year_NA", "NA", TRUE),
                   selectizeInput("regions", "Region", "Skeena"),
                   selectizeInput("source", "Data Source", "RESULTS", multiple = TRUE, selected = "RESULTS")
                   )
            )
  ),
  
  tabPanel(HTML ("Add New Record"),
           # tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")),
          fluidRow(
              ## form
              column(8, offset = 1, br(),
                     fluidRow(
                     div(id = "form", 
                         h2("Create New Offsite Species Record"),
                                  h3("Species"),
                                  checkboxInput("FD", "Douglas Fir", FALSE),
                                  checkboxInput("LW", "Western Larch", FALSE),
                                  checkboxInput("CW", "Western Red Cedar", FALSE),
                                  selectInput("bgc_input", h3("BGC"), levels(bec_rsk$ZONE)),
                                  textInput("opening_ID", h3("Opening ID")),
                                  textInput("treatment_unit", h3("Activity Treatment Unit ID")),
                                  textInput("seedlot", h3("Seedlot")),
                                  textInput("number_planted", h3("Number Planted")),
                                  textInput("area_planted", h3("Area Planted (hectares)")),
                                  numericInput("age", h3("Age"), 0),
                                  h3("Last Assessment Date"),
                                  dateInput("last_assessment_date", NULL), br(),
                         actionButton("submit_form", "Create")
                           )
                         )
                     
            )
    )
  )
)

