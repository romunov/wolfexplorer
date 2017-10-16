observe({
  if (nrow(allData()) > 0) {
    mcpIn <- input$mcp
    
    if (is.null(mcpIn)) { return(NULL) }
    
    if (mcpIn) {
      # get data for all selected animals, adult and otherwise
      # prepare parents data
      parent <- wolfPicks()
      xy <- addParentageData(x = parent, parents = inputFileParentage())
      
      if (length(input$animals) > 0) {
        parent <- xy[(xy$animal %in% input$animals), ]
      } else {
        parent <- xy[0, ]
      }
      
      if (nrow(parent) < 1) {
        return(NULL)
      }
      
      parent$class <- "parent"
      
      # prepare offspring data
      offspring <- fOffs()[fOffs()$animal %in% input$offspring, ]
      offspring <- addParentageData(x = offspring, parents = inputFileParentage())
      
      if (nrow(offspring) > 0) {
        offspring$class <- "offspring"
        xy <- do.call(rbind, list(parent, offspring))
      } else {
        xy <- parent
      }
      
      # create polygon for each animal
      ani.list <- split(xy, f = droplevels(xy$animal))
      mcp <- sapply(ani.list, FUN = calChull, simplify = FALSE)
      
      # renumber IDs, modified from https://gis.stackexchange.com/a/234030
      nms <- names(ani.list)
      mcp <- lapply(1:length(mcp), function(i, mcp, nms) {
        spChFIDs(mcp[[i]], nms[i])
      }, mcp = mcp, nms = nms)
      
      xy.popup <- lapply(ani.list, FUN = populatePolygonPopup)
      xy.popup <- unname(xy.popup)
    
      mcp <- SpatialPolygons(lapply(mcp, function(x) {x@polygons[[1]]}))
      
      pal <- colorFactor(palette = c("#d7191c", "#2c7bb6"),
                         levels = c("parent", "offspring"),
                         ordered = TRUE)
      
      # find unique class of polygons - which corresponds to list element in xy
      xy.class <- sapply(ani.list, FUN = function(x) {unique(x$class)})
      
      leafletProxy(mapId = "map") %>%
        clearGroup(group = "mcp") %>%
        addPolygons(data = mcp, 
                    stroke = TRUE,
                    color = "black",
                    weight = 0.01,
                    fill = TRUE, 
                    fillColor = pal(xy.class),
                    fillOpacity = input$mcp_opacity,
                    highlightOptions = highlightOptions(color = "white", weight = 2,
                                                        stroke = TRUE,
                                                        bringToFront = TRUE),
                    popup = xy.popup,
                    # label = xy.popup,
                    group = "mcp")
    } else {
      leafletProxy(mapId = "map") %>% 
        clearGroup(group = "mcp")
    }
  }
})
