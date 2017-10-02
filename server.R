function(input, output, session) {
  
  # subset data based on input from slider and other input fields  
  filteredData <- reactive({
    xy[(xy$animal %in% input$animals) & (xy$time > min(input$datumrange) & xy$time < max(input$datumrange)), ]
  })
  
  output$map <- renderLeaflet({
    leaflet(xy) %>% 
      addTiles() %>%
      fitBounds(~min(lng), ~min(lat), ~max(lng), ~max(lat))
  })
  
  observe({
    outmap <- leafletProxy("map", data = filteredData()) %>%
      clearMarkers() %>% clearShapes() %>%
      addCircleMarkers(lat = ~lat, lng = ~lng, radius = PS, weight = 1,
                       color = "#777777", data = xy)
    
    # add lines of selected animals
    for (i in unique(filteredData()$animal)) {
      outmap <- addPolylines(map = outmap, lng = ~lng, lat = ~lat, data = filteredData()[filteredData()$animal == i, ])
    }
    
    # finally overlay points of selected animals
    outmap %>% addCircleMarkers(lat = ~lat, lng = ~lng, radius = PS, weight = 1,
                                color = "#2E86C1", fillOpacity = 0.7,
                                popup = paste("Animal:", filteredData()$animal, "on", filteredData()$time, sep = " "))
    
    outmap
  })
}
