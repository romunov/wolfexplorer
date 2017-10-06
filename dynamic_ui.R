observe({
  xy <- allData()
  
  if (nrow(xy) > 0) { 
    ani <- sprintf("Animals: %s", length(unique(xy$animal)))
    sam <- sprintf("Samples: %s", nrow(xy))
  } else {
    ani <- sprintf("Animals: %s", 0)
    sam <- sprintf("Samples: %s", 0)
  }
  
  
  output$notifications <- renderMenu({
    dropdownMenu(type = "notifications", 
                 notificationItem(text = ani,
                                  icon("paw")),
                 notificationItem(text = sam, icon("flask")))
  })
})

observe({
  output$menu_data <- renderMenu({
    menuItem("Data", tabName = "upload", icon = icon("upload"), startExpanded = TRUE, 
             menuSubItem(text = "Samples data", tabName = "data_samples"),
             menuSubItem(text = "Parentage data", tabName = "data_parentage"))
  })
})


observe({
  if (nrow(allData()) == 0) {
    output$comment <- renderUI({
      h4("Load some data first")
    })
  } else {
    output$comment <- renderUI({ NULL })
  }
})

observe({
  if (nrow(allData()) > 0) {
    output$animals <- renderUI({
      xy <- allData()
      selectInput("animals", "Select Animal", multiple = TRUE, choices = unique(xy$animal)) })
  } else {
    output$animals <- renderUI({ NULL })
  }
})

observe({
  if (nrow(allData()) == 0) {
    output$sliderDate <- renderUI({ NULL })
  } else {
    output$sliderDate <- renderUI({
      sliderInput("datumrange", "Date range", min = min(allData()$date), max = max(allData()$date),
                  value = range(allData()$date), step = 1)
    })
  }
}) 

observe({
  if (nrow(allData()) == 0) {
    output$parent_opacity <- renderUI({
      NULL    
    })
  } else {
    output$parent_opacity <- renderUI({
      sliderInput("parent_opacity", "Parent opacity", min = 0, max = 1,
                  value = 0.8, step = 0.1, dragRange = FALSE)
    })
  }
})

observe({
  if (nrow(fOffs()) == 0) {
    output$offspring_opacity <- renderUI({
      NULL
    })
  } else {
    output$offspring_opacity <- renderUI({
      sliderInput("offspring_opacity", "Offspring opacity", min = 0, max = 1,
                  value = 0.8, step = 0.1, dragRange = FALSE)
    })
  }
})

observe({
  if (nrow(allData()) == 0) {
    output$dotSize <- renderUI({ NULL })
  } else {
    output$dotSize <- renderUI({
      sliderInput("dotSize", "Marker size", min = 1, max = 50,
                  value = 5, step = 1, dragRange = FALSE)
    })
  }
})

observe({
  # If there is some input in input$animal, display this menu
  picks <- wolfPicks()
  sibs <- fOffs()
  if (nrow(sibs) == 0) {
    output$offspring <- renderUI({ NULL })
  } else {
    output$offspring <- renderUI({
      selectInput("offspring", "Offspring", multiple = TRUE, choices = sibs$animal)
    })
  }
})
