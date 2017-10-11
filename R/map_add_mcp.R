observe({
  if (nrow(allData()) > 0) {
    mcpIn <- input$mcp
    if (is.null(mcpIn)) { NULL }
    if (isTRUE(mcpIn)) {
      offInput <- input$offspring
      parent <- wolfPicks()
      offspring <- fOffs()[fOffs()$animal %in% offInput, ]
      xy <- do.call(rbind, list(parent, offspring))
      print(xy)
      ani.list <- split(xy, f = xy$animal)
      print(ani.list[[1]])
      mcp <- sapply(ani.list, FUN = calChull, simplify = FALSE)
      print(mcp[[1]])
      mcp <- SpatialPolygons(lapply(mcp, function(x){x@polygons[[1]]}))
      
      leafletProxy(mapId = "map") %>%
        addPolygons(data = mcp, 
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
