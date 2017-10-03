function(input, output, session) {
  
  # Create map with no data, but do specify bounds
  output$map <- renderLeaflet({
    leaflet(xy) %>% 
      addProviderTiles(providers$Stamen.Terrain,
                       options = providerTileOptions(noWrap = TRUE, detectRetina = TRUE, reuseTiles = TRUE)) %>%
      fitBounds(~min(lng), ~min(lat), ~max(lng), ~max(lat))
  })
  
  # add grey markers
  observe({
    leafletProxy(mapId = "map", data = xy) %>%
      clearMarkers() %>% clearShapes() %>% 
      addCircleMarkers(lat = ~lat, lng = ~lng, radius = PS, weight = 1,
                       opacity = 0.1, data = xy, layerId = xy$id, fillColor = "black", 
                       popup = paste(xy$type, "from", xy$animal, "on", xy$time, sep = " "))
  })
  
  # subset data based on input from slider and other input fields  
  filteredData <- reactive({
    xy[(xy$animal %in% input$animals) & (xy$time > min(input$datumrange) & xy$time < max(input$datumrange)), ]
  })
  
  fSibs <- reactive({
    ## Filter out siblings from all data
    x <- filteredData()$animal
    sibs <- siblings[siblings$mother %in% x | siblings$father %in% x, "sibling"]
    xy.sibs <- xy[(xy$animal %in% sibs) & (xy$time >= min(input$datumrange) & xy$time <= max(input$datumrange)), ] 
    list(xy = xy.sibs, sibs = xy.sibs$animal)
  })
  
  observe({
    
    # prime map with filtered data for animals
    outmap <- leafletProxy(mapId = "map", data = filteredData()) 
    
    # add lines and points of selected animals
    if (nrow(filteredData()) > 0) {
      for (i in unique(filteredData()$animal)) {
        outmap <- addPolylines(map = outmap, lng = ~lng, lat = ~lat,
                               data = filteredData()[filteredData()$animal == i, ],
                               color = "red", opacity = 0.7, weight = 4)
      }
      
      # add points for animals
      outmap <- outmap %>%
        removeMarker(layerId = filteredData()$id) %>% # remove grey point before overplotting marker
        addMarkers(lat = ~lat, lng = ~lng, icon = ~icons[filteredData()$type])
    }
    
    # Add lines and points of potential siblings
    
    if (nrow(fSibs()$xy) > 0) {
      # Draws lines for siblings
      for (i in unique(fSibs()$xy$animal)) {
        outmap <- addPolylines(map = outmap, lng = ~lng, lat = ~lat,
                               data = fSibs()$xy[fSibs()$xy$animal == i, ],
                               color = "orange", opacity = 0.7, weight = 4)
      }

      # Draws points for siblings
      outmap <- outmap %>%
        removeMarker(layerId = fSibs()$xy$id) %>%
        addMarkers(lat = ~lat, lng = ~lng, icon = ~icons[fSibs()$xy$type], data = fSibs()$xy[fSibs()$xy$animal %in% input$siblings, ])
    }
    
    if (nrow(filteredData()) > 0) {
      output$siblings <- renderUI({
        selectInput("siblings", "Siblings", multiple = TRUE, choices = fSibs()$sibs)
      })
    }
    
    outmap
  })
}
