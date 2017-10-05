library(shiny)
library(shinydashboard)
library(leaflet)
library(RColorBrewer)
library(rhandsontable)
library(DT)
# source("generate_fake_data.R")
source("global.R")

#### UI ####
header <- dashboardHeader(title = "wolfexplorer",
                          # Set height of dashboardHeader
                          tags$li(class = "dropdown",
                                  tags$style(".main-header {max-height: 25px}"),
                                  tags$style(".main-header .logo {height: 25px; line-height: 25px;}"),
                                  tags$style(".sidebar-toggle {height: 25px; padding-top: 2px !important;}"),
                                  tags$style(".navbar {min-height:25px !important}")
                          )
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Explore data", tabName = "explore", icon = icon("search")),
    menuItem("Data input", tabName = "upload", icon = icon("upload"), startExpanded = TRUE,
             menuSubItem(text = "Submit data", tabName = "data_samples"),
             menuSubItem(text = "Submit parentage data", tabName = "data_parentage"))
  )
)

body <- dashboardBody(
  tags$style(type = "text/css", "#map {height: calc(100vh - 55px) !important;}"),
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
                              uiOutput("offspring"),
                              uiOutput("opacity")
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
  
  inputFileSamples <- reactive({
    x <- input$data_samples
    if (is.null(x)) {
      data.frame(lng = NA, lat = NA, time = NA, type = NA, animal = NA, id = NA)[0, ]
    } else {
      read.csv(x$datapath, header = TRUE, sep = ",",
               encoding = "UTF-8", stringsAsFactors = FALSE, 
               colClasses = c("numeric", "numeric", "Date", "character", "character"))
    }
  })
  
  inputFileParentage <- reactive({
    x <- input$data_parentage
    if (is.null(x)) {
      data.frame(sibling = NA, mother = NA, father = NA)[0, ]
    } else {
      read.csv(x$datapath, header = TRUE, sep = ",",
               encoding = "UTF-8", stringsAsFactors = FALSE,
               colClasses = "character")
    }
  })
  
  #### VIEW UPLOADED DATA ####
  
  output$uploadSampleData <- renderDataTable({
    x <- inputFileSamples()
    DT::datatable(data = x, filter = "top", options = list(pageLength = 15))
  })
  
  observe({
    x <- inputFileSamples()
    if (nrow(x) == 0) {
      output$view_samples <- renderUI({ NULL })
    } else {
      output$view_samples <- renderUI({
        dataTableOutput("uploadSampleData")
      })
    }
  })
  
  output$uploadParentageData <- renderDataTable({
    x <- inputFileParentage()
    DT::datatable(data = x, filter = "top", options = list(pageLength = 15))
  })
  
  observe({
    x <- inputFileParentage()
    if (nrow(x) == 0) {
      output$view_parentage <- renderUI({ NULL })
    } else {
      output$view_parentage <- renderUI({
        dataTableOutput("uploadParentageData")
      })
    }
  })
  
  #### CREATE VARIABLES ####
  
  # All sample data
  allData <- reactive({
    xy <- inputFileSamples()
  })
  
  # Subset data based on input from slider
  fData <- reactive({
    xy <- inputFileSamples()
    if (nrow(xy) > 0) {
      xy[(xy$time >= input$datumrange[1] & xy$time <= input$datumrange[2]), ]
    } else {
      xy[0, ]
    }
  })
  
  wolfPicks <- reactive({
    xy <- fData()
    if (nrow(xy) > 0 & length(input$animals) > 0) {
      xy[(xy$animal %in% input$animals), ]
    } else {
      xy[0, ]
    }
  })
  
  # Filter out offspring from data
  fOffs <- reactive({
    xy <- fData()
    x <- wolfPicks()$animal
    offspring <- inputFileParentage()
    if (nrow(offspring) > 0) {
      offs <- offspring[offspring$mother %in% x | offspring$father %in% x, "sibling"]
      xy[(xy$animal %in% offs) & (xy$time >= input$datumrange[1] & xy$time <= input$datumrange[2]), ]
    } else {
      offspring
    }
  })
  
  #### DYNAMIC UI ####
  
  observe({
    if (nrow(allData()) == 0) {
      output$comment <- renderUI({
        h4("Load some data first")
      })
    } else {
      output$comment <- renderUI({ NULL })
    }
  })
  
  observe({
    if (nrow(allData()) > 0) {
      output$animals <- renderUI({
        xy <- allData()
        selectInput("animals", "Select Animal", multiple = TRUE, choices = unique(xy$animal)) })
    } else {
      output$animals <- renderUI({ NULL })
    }
  })
  
  observe({
    if (nrow(allData()) == 0) {
      output$sliderDate <- renderUI({ NULL })
    } else {
      output$sliderDate <- renderUI({
        sliderInput("datumrange", "Datum range", min = min(allData()$time), max = max(allData()$time),
                    value = range(allData()$time), step = 1)
      })
    }
  }) 
  
  observe({
    if (nrow(allData()) == 0) {
      output$opacity <- renderUI({ NULL })
    } else {
      output$opacity <- renderUI({
        sliderInput("opacityrange", "Line/Point opacity", min = 0, max = 1,
                    value = 0.8, step = 0.1, dragRange = FALSE)
      })
    }
  })
  
  observe({
    # If there is some input in input$animal, display this menu
    picks <- wolfPicks()
    sibs <- fOffs()
    print(sibs)
    if (nrow(sibs) == 0) {
      output$offspring <- renderUI({ NULL })
    } else {
      output$offspring <- renderUI({
        selectInput("offspring", "Offspring", multiple = TRUE, choices = sibs$animal)
      })
    }
  })
  
  #### LEAFLET MAGIC ####
  
  # Create empty map with specified bounds
  output$map <- renderLeaflet({
    leaflet() %>% 
      addProviderTiles(provider = providers$Stamen.Terrain,
                       options = providerTileOptions(noWrap = TRUE,
                                                     detectRetina = TRUE,
                                                     reuseTiles = TRUE)) %>% 
      setView(lng = 14.815333, lat = 46.119944, zoom = 8)
  })
  
  # Add markers and lines for selected animals to map
  observe({
    xy <- allData()
    picks <- wolfPicks()
    if (nrow(xy) > 0) {
      
      # Add "baselayer"
      outmap <- leafletProxy("map") %>% 
        clearMarkers() %>%
        clearShapes() %>%
        addCircleMarkers(data = xy, lat = ~lat, lng = ~lng, 
                         radius = PS, 
                         stroke = TRUE, 
                         weight = 0.8,
                         opacity = 0.5,
                         color = "black",
                         fill = TRUE,
                         fillOpacity = 0.2, 
                         fillColor = "black", 
                         layerId = paste("allMarkers", xy$id, sep = " "),
                         popup = paste(xy$type, "from", xy$animal, "on", xy$time, sep = " "))
      
      
      if (nrow(picks) > 0) {
        # Add lines
        for (i in unique(picks$animal)) {
          outmap <- addPolylines(map = outmap, lng = ~lng, lat = ~lat, 
                                 layerId = paste("aniLines", picks$id[picks$animal == i], sep = " "),
                                 data = picks[picks$animal == i, ],
                                 color = "black", 
                                 opacity = input$opacityrange, 
                                 weight = 1)
        }
        # Add markers
        outmap %>%
          removeMarker(layerId = paste("allMarkers", picks$id, sep = " ")) %>% 
          addCircleMarkers(data = picks,
                           lat = ~lat, lng = ~lng, 
                           radius = PS, 
                           stroke = FALSE,
                           fillColor = ~pal(type),
                           fillOpacity = input$opacityrange, 
                           layerId = paste("aniMarkers", picks$id, sep = " "),
                           popup = paste(picks$type, "from", picks$animal, "on", picks$time, sep = " "))
      }
    }
  })
  
  # Add markers and lines for selected offspring to map
  observe({
    sibsInput <- input$offspring
    sibs <- fOffs()[fOffs()$animal %in% sibsInput, ]
    
    out.sibs <- leafletProxy("map") %>% 
      # Remove all previous points and lines
      clearGroup(group = "sibMarkers") %>% 
      clearGroup(group = "sibLines")
    
    if (nrow(sibs) > 0) {
      out.sibs <- leafletProxy("map") %>% 
        # Remove all previous points and lines
        clearGroup(group = "sibMarkers") %>% 
        clearGroup(group = "sibLines")
      # Add lines
      for (i in unique(sibs$animal)) {
        out.sibs <- addPolylines(map = out.sibs, lng = ~lng, lat = ~lat, 
                                 layerId = paste("sibLines", sibs$id[sibs$animal == i], sep = " "),
                                 data = sibs[sibs$animal == i, ],
                                 color = "#fdc086", opacity = input$opacityrange, weight = 1, group = "sibLines")
      }
      # Add points
      out.sibs %>%
        removeMarker(layerId = paste("allMarkers", sibs$id, sep = " ")) %>% 
        addCircleMarkers(lat = ~lat, lng = ~lng, 
                         data = sibs, 
                         radius = PS,
                         stroke = FALSE,
                         fillColor = ~pal(type),
                         fillOpacity = input$opacityrange,
                         layerId = paste("sibMarkers", sibs$id, sep = " "),
                         group = "sibMarkers")
    }
  })
}

shinyApp(ui, server)
