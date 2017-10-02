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
    leafletProxy("map", data = filteredData()) %>%
      clearMarkers() %>%
      addCircleMarkers(lat = ~lat, lng = ~lng, radius = PS, weight = 1, color = "#777777", data = xy) %>%
      addCircleMarkers(lat = ~lat, lng = ~lng, radius = PS, weight = 1, color = "#2E86C1", fillOpacity = 0.7)
  })
}
