function(input, output, session) {
  
  output$map <- renderLeaflet({
    leaflet(xy) %>% 
      addProviderTiles(providers$Stamen.Terrain,
                       options = providerTileOptions(noWrap = TRUE, detectRetina = TRUE, reuseTiles = TRUE)) %>%
      fitBounds(~min(lng), ~min(lat), ~max(lng), ~max(lat))
  })
  
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
  
  
  observe({
    # Filter out siblings
    x <- filteredData()$animal
    sibs <- siblings[siblings$mother %in% x | siblings$father %in% x, "sibling"]
    xy.sibs <- xy[(xy$animal %in% sibs) & (xy$time > min(input$datumrange) & xy$time < max(input$datumrange)), ] 
    xy.sibs <- xy.sibs[xy.sibs$animal %in% input$sibling, ]
    
    outmap <- leafletProxy(mapId = "map", data = filteredData()) 
    
    # add lines of selected animals
    if (nrow(filteredData()) > 0) {
      for (i in unique(filteredData()$animal)) {
        outmap <- addPolylines(map = outmap, lng = ~lng, lat = ~lat,
                               data = filteredData()[filteredData()$animal == i, ],
                               color = "red", opacity = 0.7, weight = 4)
      }
    }
    
    # Finally overlay points of selected animals
    outmap <- outmap %>%
      removeMarker(layerId = filteredData()$id) %>% 
      addMarkers(lat = ~lat, lng = ~lng, icon = ~icons[filteredData()$type])
    
    # Checks if there are any siblings selected and then draws them
    
    if (nrow(xy.sibs) > 0) {
      # Draws lines for siblings
      for (i in unique(xy.sibs$animal)) {
        outmap <- addPolylines(map = outmap, lng = ~lng, lat = ~lat,
                               data = xy.sibs[xy.sibs$animal == i, ],
                               color = "orange", opacity = 0.7, weight = 4)
      }
      
      # Draws points for siblings
      outmap <- outmap %>% 
        removeMarker(layerId = xy.sibs$id[xy.sibs$animal %in% input$siblings]) %>% 
        addMarkers(lat = ~lat, lng = ~lng, icon = ~icons[xy.sibs$type], data = xy.sibs[xy.sibs %in% input$siblings, ])
    }
    
    if (nrow(filteredData()) > 0) {
      output$siblings <- renderUI({
        selectInput("siblings", "Siblings", multiple = TRUE, choices = sibs)
      })
    }
    
    outmap
  })
}
