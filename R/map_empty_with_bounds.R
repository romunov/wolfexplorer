# Create empty map with specified bounds
output$map <- renderLeaflet({
  leaflet(options = leafletOptions(zoomControl = FALSE)) %>% 
    addProviderTiles(provider = providers$Stamen.Terrain,
                     options = providerTileOptions(noWrap = TRUE,
                                                   detectRetina = TRUE,
                                                   reuseTiles = TRUE)) %>% 
    setView(lng = 14.815333, lat = 46.119944, zoom = 8)
})

observeEvent(input$uploadSampleData_row_last_clicked, {
  x <- inputFileSamples()
  selectedRow <- input$uploadSampleData_row_last_clicked
  
  leafletProxy('map') %>%
    setView(lng = x[selectedRow, 'lng'], lat = x[selectedRow, 'lat'], zoom = 10)
  
}, ignoreInit = TRUE)
