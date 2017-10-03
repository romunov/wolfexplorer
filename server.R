function(input, output, session) {
  
  # subset data based on input from slider and other input fields  
  filteredData <- reactive({
    xy[(xy$animal %in% input$animals) & (xy$time > min(input$datumrange) & xy$time < max(input$datumrange)), ]
  })
  
  output$map <- renderLeaflet({
    leaflet(xy) %>% 
      addProviderTiles(providers$Stamen.Terrain,
                       options = providerTileOptions(noWrap = TRUE, detectRetina = TRUE, reuseTiles = TRUE)) %>%
      fitBounds(~min(lng), ~min(lat), ~max(lng), ~max(lat))
  })
  
  observe({
    outmap <- leafletProxy(mapId = "map", data = filteredData()) %>%
      clearMarkers() %>% clearShapes() %>% 
      addCircleMarkers(lat = ~lat, lng = ~lng, radius = PS, weight = 1,
                       opacity = 0.1, data = xy, layerId = xy$id, fillColor = "black",
                       popup = paste(xy$type, "from", xy$animal, "on", xy$time, sep = " "))
      
      # add lines of selected animals
      for (i in unique(filteredData()$animal)) {
        outmap <- addPolylines(map = outmap, lng = ~lng, lat = ~lat,
                               data = filteredData()[filteredData()$animal == i, ],
                               color = "black", opacity = 0.5, weight = 2)
      }
    
    # finally overlay points of selected animals
    outmap %>%
      removeMarker(layerId = filteredData()$id) %>% 
      addMarkers(lat = ~lat, lng = ~lng, icon = ~icons[filteredData()$type])
  })
}
