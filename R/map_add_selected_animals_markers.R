# Add markers and lines for selected animals to map
r.pal <- reactiveValues()
r.pal$pal <- NULL

observe({
  PS <- PS()
  xy <- allData()
  
  if (nrow(xy) > 0) {
    # Adds parentage data to sample data if provided.
    xy <- addParentageData(x = xy, parents = inputFileParentage())
    
    # Subset potential animals selected in the selectInput menu.
    if (length(input$animals) > 0) {
      picks <- xy[(xy$animal %in% input$animals), ]
    } else {
      picks <- xy[0, ]
    }
    
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
                       group = "All samples",
                       popup = populatePopup(xy)) 
    
    if (nrow(picks) > 0) {
      # Add lines
      for (i in unique(picks$animal)) {
        outmap <- addPolylines(map = outmap, lng = ~lng, lat = ~lat, 
                               layerId = paste("aniLines", picks$id[picks$animal == i], sep = " "),
                               group = "Selected animals",
                               data = picks[picks$animal == i, ],
                               color = "black", 
                               opacity = input$parent_opacity, 
                               weight = 0.5)
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
                         group = "Selected animals",
                         popup = populatePopup(picks)) %>%
        clearControls() %>%
        addLegend("bottomright",
                  pal = r.pal$pal, values = xy$sample_type,
                  title = "Sample type",
                  opacity = 1)
    }
  }
})
