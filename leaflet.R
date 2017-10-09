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

# Add markers and lines for selected animals to map
observe({
  PS <- PS()
  xy <- allData()
  picks <- wolfPicks()
  
  if (nrow(xy) > 0) {
    # Create custom palette based on all samples. This should prevent the legend
    # from changing if subset should not contain all levels.
    pal <- colorFactor(palette = colors.df$mapping$sample_type_colors,
                       levels = colors.df$mapping$sample_type_levels,
                       ordered = TRUE)
    
    # Add "baselayer"
    outmap <- leafletProxy("map") %>% 
      clearMarkers() %>%
      clearShapes() %>%
      addCircleMarkers(data = xy, lat = ~lat, lng = ~lng, 
                       radius = 5, 
                       stroke = TRUE, 
                       weight = 0.8,
                       opacity = 0.5,
                       color = "black",
                       fill = TRUE,
                       fillOpacity = 0.2, 
                       fillColor = "black", 
                       layerId = paste("allMarkers", xy$id, sep = " "),
                       popup = populatePopup(xy)) 
    
    if (nrow(picks) > 0) {
      # Add lines
      for (i in unique(picks$animal)) {
        outmap <- addPolylines(map = outmap, lng = ~lng, lat = ~lat, 
                               layerId = paste("aniLines", picks$id[picks$animal == i], sep = " "),
                               data = picks[picks$animal == i, ],
                               color = "black", 
                               opacity = input$parent_opacity, 
                               weight = 1)
      }
      # Add markers
      outmap %>%
        removeMarker(layerId = paste("allMarkers", picks$id, sep = " ")) %>% 
        addCircleMarkers(data = picks,
                         lat = ~lat, lng = ~lng, 
                         radius = PS, 
                         stroke = FALSE,
                         fillColor = ~pal(sample_type),
                         fillOpacity = input$parent_opacity, 
                         layerId = paste("aniMarkers", picks$id, sep = " "),
                         popup = populatePopup(picks)) %>%
        clearControls() %>%
        addLegend("bottomright",
                  pal = pal, values = picks$sample_type,
                  title = "Sample type",
                  opacity = 1)
    }
  }
})

# Add markers and lines for selected offspring to map
observe({
  PS <- PS()
  offInput <- input$offspring
  off <- fOffs()[fOffs()$animal %in% offInput, ]
  
  out.off <- leafletProxy("map") %>% 
    # Remove all previous points and lines
    clearGroup(group = "sibMarkers") %>% 
    clearGroup(group = "sibLines")
  
  if (nrow(off) > 0) {
    out.off <- leafletProxy("map") %>% 
      # Remove all previous points and lines
      clearGroup(group = "sibMarkers") %>% 
      clearGroup(group = "sibLines")
    # Add lines
    for (i in unique(off$animal)) {
      out.off <- addPolylines(map = out.off, lng = ~lng, lat = ~lat, 
                              layerId = paste("sibLines", off$id[off$animal == i], sep = " "),
                              data = off[off$animal == i, ],
                              color = "#fdc086", opacity = input$offspring_opacity, weight = 1, group = "sibLines")
    }
    # Add points
    out.off %>%
      removeMarker(layerId = paste("allMarkers", off$id, sep = " ")) %>% 
      addCircleMarkers(lat = ~lat, lng = ~lng, 
                       data = off, 
                       radius = PS,
                       stroke = FALSE,
                       fillColor = ~pal(sample_type),
                       fillOpacity = input$offspring_opacity,
                       layerId = paste("sibMarkers", off$id, sep = " "),
                       group = "sibMarkers")
  }
})
