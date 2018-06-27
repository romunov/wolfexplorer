library(shiny)
library(shinydashboard)
library(shinyjs)
library(leaflet)
library(RColorBrewer)
library(DT)
library(sp)
library(rgdal)
library(data.table)
library(ggplot2)
library(colourpicker)
library(tidyr)
library(plyr)
library(rgeos)
library(htmltools)
library(kinship2)

source("./R/functions.R")
# source("./R/prepForPedigree.R")

# Add header.
source("./R/base_header.R", local = TRUE)

# Add sidebar.
source("./R/base_sidebar.R", local = TRUE)

# Add body.
source("./R/base_body.R", local = TRUE)

ui <- dashboardPage(header, sidebar, body, skin = "black")

#### SERVER ####

server <- function(input, output) {
  
  #### FILE INPUT ####  
  source("./R/file_input.R", local = TRUE)
  
  #### CREATE VARIABLES ####
  source("./R/create_variables.R", local = TRUE)
  
  #### VIEW UPLOADED DATA ####
  source("./R/view_data.R", local = TRUE)
  
  #### DYNAMIC UI ####
  source("./R/dynamic_ui.R", local = TRUE)
  
  #### LEAFLET MAGIC ####
  source("./R/leaflet.R", local = TRUE)
  
  #### PLOT PEDIGREE ####
  source("./R/plot_pedigree.R", local = TRUE)
  
}

shinyApp(ui, server)
