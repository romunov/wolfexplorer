# Add mortality markers to map
observe({
  xy <- allData()
  if (nrow(xy) > 0) {
    is.muerto <- input$muerto
    if (is.null(is.muerto)) { NULL }
    if (isTRUE(is.muerto)) {
      xy <- mortality()
      muerto <- makeIcon(iconUrl = "icons/death.png", iconWidth = 20, iconHeight = 20)
      leafletProxy(mapId = "map", data = xy) %>%
        addMarkers(lat = ~lat, lng = ~lng,
                   icon = muerto, 
                   popup = populatePopup(xy),
                   group = "muerto")
    }
    if (!isTRUE(is.muerto)) {
      leafletProxy(mapId = "map") %>% 
        clearGroup(group = "muerto")
    }
  }
})
