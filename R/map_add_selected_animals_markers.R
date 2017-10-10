# Add markers and lines for selected animals to map
r.pal <- reactiveValues()
r.pal$pal <- NULL

observe({
  PS <- PS()
  xy <- allData()
  picks <- wolfPicks()
  
  if (nrow(xy) > 0) {
    # Create custom palette based on all samples. This should prevent the legend
    # from changing if subset should not contain all levels.
    r.pal$pal <- colorFactor(palette = colors.df$mapping$sample_type_colors,
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
                         fillColor = ~r.pal$pal(sample_type),
                         fillOpacity = input$parent_opacity, 
                         layerId = paste("aniMarkers", picks$id, sep = " "),
                         popup = populatePopup(picks)) %>%
        clearControls() %>%
        addLegend("bottomright",
                  pal = r.pal$pal, values = xy$sample_type,
                  title = "Sample type",
                  opacity = 1)
    }
  }
})
