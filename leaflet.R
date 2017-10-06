# Create empty map with specified bounds
output$map <- renderLeaflet({
  leaflet(options = leafletOptions(zoomControl = FALSE)) %>% 
    addProviderTiles(provider = providers$Stamen.Terrain,
                     options = providerTileOptions(noWrap = TRUE,
                                                   detectRetina = TRUE,
                                                   reuseTiles = TRUE)) %>% 
    setView(lng = 14.815333, lat = 46.119944, zoom = 8)
})

# Add markers and lines for selected animals to map
observe({
  PS <- PS()
  xy <- allData()
  picks <- wolfPicks()
  if (nrow(xy) > 0) {
    
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
  PS <- PS()
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
