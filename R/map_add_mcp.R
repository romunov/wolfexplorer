observe({
  if (nrow(allData()) > 0) {
    mcpIn <- input$mcp
    print(mcpIn)
    if (is.null(mcpIn)) { NULL }
    if (isTRUE(mcpIn)) {
      offInput <- input$offspring
      parent <- wolfPicks()
      offspring <- fOffs()[fOffs()$animal %in% offInput, ]
      
      xy <- do.call(rbind, list(parent, offspring))
      
      mcp <- xy[chull(xy$lng, xy$lat), ]
      print(mcp)
      leafletProxy(mapId = "map") %>%
        addPolygons(data = mcp, 
                    lat = ~lat, 
                    lng = ~lng, 
                    fill = TRUE, 
                    stroke = FALSE,
                    fillColor = "yellow", 
                    fillOpacity = 1,
                    group = "mcp")
    }
    if (!isTRUE(mcpIn)) {
      leafletProxy(mapId = "map") %>% 
        clearGroup(group = "mcp")
    }
  }
})
