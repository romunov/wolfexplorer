observe({
  if (nrow(allData()) > 0) {
    mcpIn <- input$mcp
    dmcl <- TRUE
    
    if (is.null(mcpIn)) { return(NULL) }
    
    if (mcpIn) {
      # Get data for all selected animals, adult and otherwise prepare parents data.
      parent <- wolfPicks()
      xy <- addParentageData(x = parent, parents = inputFileParentage())
      
      if (length(input$animals) > 0) {
        parent <- xy[(xy$reference_sample %in% input$animals), ]
      } else {
        parent <- xy[0, ]
      }
      
      if (nrow(parent) < 1) {
        return(NULL)
      }
      
      parent$class <- "parent"
      
      # prepare offspring data
      offspring <- fOffs()[fOffs()$reference_sample %in% input$offspring, ]
      offspring <- addParentageData(x = offspring, parents = inputFileParentage())
      
      if (nrow(offspring) > 0) {
        offspring$class <- "offspring"
        xy <- do.call(rbind, list(parent, offspring))
      } else {
        xy <- parent
      }
      
      # create polygon for each animal
      ani.list <- split(xy, f = droplevels(xy$reference_sample))
      mcp <- sapply(ani.list, FUN = calChull, simplify = FALSE)
      
      if (dmcl) {
        # This will be needed for connecting centroids of polygons.
        mcp.centroid <- sapply(mcp, FUN = gCentroid)
      }
      
      # Renumber IDs, modified from https://gis.stackexchange.com/a/234030
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
      
      # Find unique class of polygons - which corresponds to list element in xy.
      xy.class <- sapply(ani.list, FUN = function(x) {unique(x$class)})
      xy.class <- sapply(xy.class, "[", 1)
      
      leafletProxy(mapId = "map") %>%
        clearGroup(group = "MCP") %>%
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
                    group = "MCP")
      
      # If selected, connect centroids so that offspring is connected to the parent.
      cent.parents <- input$animals
      
      for (i in cent.parents) {
        # If parent has any offspring (selected), connect centroids as described above.
        num.offspring <- xy[xy$mother %in% i | xy$father %in% i, ]  # find all offspring for parent i
        
        if (nrow(num.offspring) > 0) {
          cent.i.offspring <- unique(num.offspring$reference_sample)  # isolate offspring animals
          
          for (j in cent.i.offspring) {
            if (any(names(mcp.centroid) %in% j)) {
              con.centroids <- rbind(coordinates(mcp.centroid[[i]]), 
                                     coordinates(mcp.centroid[[j]]))
              
              leafletProxy(mapId = "map") %>%
                addPolylines(data = con.centroids,
                             color = "#ffff00",
                             weight = 0.75,
                             group = "Centroid connections")
            }
          }
        }
      }
    } else {
      leafletProxy(mapId = "map") %>% 
        clearGroup(group = "MCP")
    }
  }
})
