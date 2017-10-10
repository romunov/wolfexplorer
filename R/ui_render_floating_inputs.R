# Render floating inputs which control selection on the map.
observe({
  output$menu_data <- renderMenu({
    menuItem("Load data", tabName = "upload", icon = icon("paw"), startExpanded = TRUE, 
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

# If there is some input in input$animal, display this menu
observe({
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
