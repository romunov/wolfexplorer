function(input, output, session) {
  
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
    print(fData())
    # Creates "baselayer"
    outmap <- leafletProxy("map") %>% 
      clearMarkers() %>%
      clearShapes() %>%
      addCircleMarkers(data = xy, lat = ~lat, lng = ~lng, radius = 7, stroke = FALSE, fill = TRUE,
                       fillOpacity = 0.3, fillColor = "black", layerId = paste("allMarkers", xy$id, sep = " "),
                       popup = paste(xy$type, "from", xy$animal, "on", xy$time, sep = " "))
    
    if (nrow(fData()) > 0) {
      # Add lines
      for (i in unique(fData()$animal)) {
        print(i)
        outmap <- addPolylines(map = outmap, lng = ~lng, lat = ~lat, 
                               layerId = paste("aniLines", fData()$id[fData()$animal == i], sep = " "),
                               data = fData()[fData()$animal == i, ],
                               color = "red", opacity = 0.7, weight = 1)
      }
      # Add markers
      outmap %>%
        removeMarker(layerId = paste("allMarkers", fData()$id, sep = " ")) %>% 
        addCircleMarkers(data = fData(),
                         lat = ~lat, lng = ~lng, radius = PS, stroke = FALSE,
                         fillOpacity = 0.7, fillColor = "red", layerId = paste("aniMarkers", fData()$id, sep = " "),
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
                                 color = "orange", opacity = 0.7, weight = 4, group = "sibLines")
      }
      # Add points
      out.sibs %>%
        addMarkers(lat = ~lat, lng = ~lng, icon = ~icons[sibs$type], 
                   layerId = paste("sibMarkers", sibs$id, sep = " "),
                   data = sibs, group = "sibMarkers")
    }
  })
}
