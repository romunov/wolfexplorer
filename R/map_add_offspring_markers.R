# Add markers and lines for selected offspring to map
observe({
  PS <- PS()
  offInput <- input$offspring
  
  off <- fOffs()[fOffs()$reference_sample %in% offInput, ]
  
  # Add parentage data if provided.
  off <- addParentageData(xy = off, parents = inputFileParentage())
  
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
    for (i in unique(off$reference_sample)) {
      out.off <- addPolylines(map = out.off, lng = ~lng, lat = ~lat, 
                              layerId = paste("sibLines", off$id[off$reference_sample == i], sep = " "),
                              group = "Offspring",
                              data = off[off$reference_sample == i, ],
                              color = "#fdc086", 
                              opacity = input$offspring_opacity, 
                              weight = 0.5)
    }
    # Add points
    out.off %>%
      addCircleMarkers(lat = ~lat, lng = ~lng, 
                       data = off, 
                       radius = PS,
                       stroke = FALSE,
                       fillColor = ~r.pal$pal(sample_type),
                       fillOpacity = input$offspring_opacity,
                       layerId = paste("sibMarkers", off$id, sep = " "),
                       group = "Offspring",
                       popup = populatePopup(off))
  }
})
