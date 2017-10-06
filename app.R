library(shiny)
library(shinydashboard)
library(leaflet)
library(RColorBrewer)
library(rhandsontable)
library(DT)
library(sp)
source("global.R")
source("GKtoWGS.R")

#### UI ####


#### HEADER ####

header <- dashboardHeader(title = "wolfexplorer"
                          # # Set height of dashboardHeader
                          # tags$li(class = "dropdown",
                          #         tags$style(".main-header {max-height: 25px}"),
                          #         tags$style(".main-header .logo {height: 25px; line-height: 25px;}"),
                          #         tags$style(".sidebar-toggle {height: 25px; padding-top: 2px !important;}"),
                          #         tags$style(".navbar {min-height:25px !important}")
                          # )
)


#### SIDEBAR ####
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Explore data", tabName = "explore", icon = icon("search")),
    menuItem("Data input", tabName = "upload", icon = icon("upload"), startExpanded = TRUE,
             menuSubItem(text = "Submit data", tabName = "data_samples"),
             menuSubItem(text = "Submit parentage data", tabName = "data_parentage"))
  )
)


#### BODY ####
body <- dashboardBody(
  tags$style(type = "text/css", "#map {height: 100% !important;}"),
  tabItems(
    tabItem(tabName = "explore",
            
            div(class="outer",
                
                tags$head(
                  # Include our custom CSS
                  includeCSS("styles.css")
                  # includeScript("gomap.js")
                ),
                
                leafletOutput("map"),
                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                              width = 330, height = "auto",
                              uiOutput("comment"),
                              uiOutput("sliderDate"),
                              uiOutput("animals"),
                              uiOutput("offspring")
                ),
                absolutePanel(id = "display_controls", class = "panel panel-default", fixed = TRUE,
                              draggable = FALSE, top = "auto", left = "auto", right = 20, bottom = 30,
                              width = 330, height = "auto",
                              uiOutput("opacity"),
                              uiOutput("dotSize")
                )
            )
    ),
    tabItem(tabName = "data_samples",
            fluidRow(
              box(solidHeader = TRUE, collapsible = TRUE, title = "Upload samples data",
                  fileInput(inputId = "data_samples", 
                            label = "Upload dataset",
                            buttonLabel = "Select data",
                            accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv"))),
              h4("Upload parentage data for full functionality")),
            br(),
            br(),
            uiOutput("view_samples")
    ),
    tabItem(tabName = "data_parentage",
            box(solidHeader = TRUE, collapsible = TRUE, title = "Upload parentage / colony data",
                fileInput(inputId = "data_parentage", 
                          label = "Upload dataset",
                          buttonLabel = "Select data",
                          accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv"))),
            br(),
            br(),
            uiOutput("view_parentage")
    )
  )
)

ui <- dashboardPage(header, sidebar, body, skin = "black")

#### SERVER ####

server <- function(input, output) {
  
  #### FILE INPUT ####  
  source("file_input.R", local = TRUE)
  
  #### VIEW UPLOADED DATA ####
  source("view_data.R", local = TRUE)
  
  #### CREATE VARIABLES ####
  source("create_variables.R", local = TRUE)
  
  #### DYNAMIC UI ####
  source("dynamic_ui.R", local = TRUE)
  
  #### LEAFLET MAGIC ####
  source("leaflet.R", local = TRUE)
  
}

shinyApp(ui, server)
