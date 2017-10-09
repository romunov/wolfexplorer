library(shiny)
library(shinydashboard)
library(leaflet)
library(RColorBrewer)
library(DT)
library(sp)
library(rgdal)
library(data.table)
library(ggplot2)
library(colourpicker)

source("global.R")
source("functions.R")

#### HEADER ####

header <- dashboardHeader(title = "wolfexplorer",
                          dropdownMenuOutput("notifications"))

#### SIDEBAR ####

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Explore data", tabName = "explore", icon = icon("map-o")),
    menuItemOutput(outputId = "menu_data"),
    menuItem("Dataset overview", tabName = "overview", icon = icon("eye")),
    menuItem("Settings", tabName = "settings", icon = icon("cogs")),
    br(),
    uiOutput("parent_opacity"),
    uiOutput("offspring_opacity"),
    uiOutput("dotSize")
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
    ),
    tabItem(tabName = "overview",
            uiOutput("stats"),
            uiOutput("graphs")
    ),
    tabItem(tabName = "settings",
            fluidRow(
            tabBox(side = "left", selected = "Colors",
                   width = 12,
                   tabPanel("General", "some general text"),
                   tabPanel("Colors",
                            colourInput("col1", "Sample type 1", "red", palette = "limited"),
                            colourInput("col2", "Sample type 2", "green", palette = "limited"),
                            colourInput("col3", "Sample type 3", "blue", palette = "limited"))
            )
            )
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


