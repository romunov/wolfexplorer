library(shiny)
library(shinydashboard)
library(leaflet)
library(RColorBrewer)
library(rhandsontable)
library(DT)
source("generate_fake_data.R")
source("global.R")

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
    menuItem("Data input", tabName = "upload", icon = icon("upload")),
    menuItem("About wolfexplorer", tabName = "about", icon = icon("paw"))
  )
)

body <- dashboardBody(
  tags$style(type = "text/css", "#map {height: calc(100vh - 55px) !important;}"),
  tabItems(
    tabItem(tabName = "about",
            h4("What is wolfexplorer?")),
    tabItem(tabName = "upload",
            fileInput(inputId = "submitFile", 
                      label = "Upload dataset",
                      buttonLabel = "Submit CSV file"),
            # accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv"),
            uiOutput("overview")
    ),
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
                              
                              sliderInput("datumrange", "Datum range", min = min(xy$time), max = max(xy$time),
                                          value = range(xy$time), step = 1),
                              uiOutput("animals"),
                              uiOutput("siblings"),
                              sliderInput("opacityrange", "Line/Point opacity", min = 0, max = 1,
                                          value = 0.8, step = 0.1, dragRange = FALSE)
                )
            )
    )
  )
)


ui <- dashboardPage(header, sidebar, body, skin = "black")

server <- function(input, output) {
  
  # dataset <- observeEvent(input$submitFile, {
  #   x <- input$file
  #   if (is.null(x))
  #     return(NULL)
  #   else {
  #     x <- read.csv(x$datapath, header = TRUE, sep = input$sep,
  #                   encoding = "UTF-8", stringsAsFactors = FALSE)
  #     x
  #   }
  # })
  # 
  # output$overview <- renderUI({
  #   box(title = "Dataset overview", solidHeader = TRUE, width = 12, collapsible = TRUE,
  #       DT::datatable(data = dataset(), filter = "top", fillContainer = TRUE)
  #   )
  # })
  
  # Create empty map with specified bounds
  output$map <- renderLeaflet({
    leaflet(data = xy) %>% 
      addProviderTiles(provider = providers$Stamen.Terrain,
                       options = providerTileOptions(noWrap = TRUE,
                                                     detectRetina = TRUE,
                                                     reuseTiles = TRUE)) %>% 
      fitBounds(~min(lng), ~min(lat), ~max(lng), ~max(lat))
  })
  
  # Subset data based on input from slider
  fData <- reactive({
    xy[(xy$animal %in% input$animals) & (xy$time >= input$datumrange[1] & xy$time <= input$datumrange[2]), ]
  })
  
  # # Subset animal in within date range
  # fDateRange <- reactive({
  #   xy[(xy$time >= input$datumrange[1] & xy$time <= input$datumrange[2]), ]
  # })
  
  # Filter out siblings from data
  fSibs <- reactive({
    x <- fData()$animal
    sibs <- siblings[siblings$mother %in% x | siblings$father %in% x, "sibling"]
    xy[(xy$animal %in% sibs) & (xy$time >= input$datumrange[1] & xy$time <= input$datumrange[2]), ]
  })
  
  # Add markers and lines for selected animals to map
  observe({
    # Creates "baselayer"
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
    
    if (nrow(fData()) > 0) {
      # Add lines
      for (i in unique(fData()$animal)) {
        outmap <- addPolylines(map = outmap, lng = ~lng, lat = ~lat, 
                               layerId = paste("aniLines", fData()$id[fData()$animal == i], sep = " "),
                               data = fData()[fData()$animal == i, ],
                               color = "black", 
                               opacity = input$opacityrange, 
                               weight = 1)
      }
      # Add markers
      outmap %>%
        removeMarker(layerId = paste("allMarkers", fData()$id, sep = " ")) %>% 
        addCircleMarkers(data = fData(),
                         lat = ~lat, lng = ~lng, 
                         radius = PS, 
                         stroke = FALSE,
                         fillColor = ~pal(type),
                         fillOpacity = input$opacityrange, 
                         layerId = paste("aniMarkers", fData()$id, sep = " "),
                         popup = paste(fData()$type, "from", fData()$animal, "on", fData()$time, sep = " "))
    }
  })
  
  output$animals <- renderUI({
    selectInput("animals", "Select Animal", multiple = TRUE, choices = unique(xy$animal))
  })
  
  
  # If there is some input in input$animal, display this menu
  observe({
    if (nrow(fData()) == 0) {
      output$siblings <- renderUI({ NULL })
    } else {
      output$siblings <- renderUI({
        selectInput("siblings", "Siblings", multiple = TRUE, choices = fSibs()$animal)
      })
    }
  })
  
  # Add markers and lines for selected siblings to map
  observe({
    sibs <- input$siblings
    sibs <- fSibs()[fSibs()$animal %in% sibs, ]
    
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





