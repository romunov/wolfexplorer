# Render notifications in the upper right corner.
observe({
  xy <- wolfPicks()
  df <- fOffs()
  offInput <- input$offspring
  offs <- df[df$animal %in% offInput, ]
  
  if (nrow(xy) > 0) {
    ani <- sprintf("Parents: %s", length(unique(xy$animal)))
    sam <- sprintf("Samples: %s", (nrow(xy) + nrow(offs)))
    off <- sprintf("Offspring: %s", length(unique(offs$animal)))
  } else {
    ani <- sprintf("Parents: %s", 0)
    sam <- sprintf("Samples: %s", 0)
    off <- sprintf("Offspring: %s", 0)
    
  }
  
  output$notifications <- renderMenu({
    dropdownMenuCustom(type = "notifications", customSentence = customSentence,
                       notificationItem(text = ani,
                                        icon("paw")),
                       notificationItem(text = off, icon("paw")),
                       notificationItem(text = sam, icon("flask")))
  })
})
