# Render floating inputs which control selection on the map.
observe({
  output$menu_data <- renderMenu({
    menuItem("View data", tabName = "view_data", icon = icon("paw"), startExpanded = TRUE, 
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
      xy <- fData()
      selectInput("animals", "Select Animal", multiple = TRUE, 
                  choices = sort(unique(xy$reference_sample))) })
  } else {
    output$animals <- renderUI({ NULL })
  }
})

observe({
  if (nrow(wolfPicks()) > 0) {
    output$mcp <- renderUI({
      checkboxInput(inputId = "mcp", label = "Show MCP", value = FALSE) })
  } else {
    output$mcp <- renderUI({ NULL })
  }
})

# Display time slider
observe({
  if (nrow(allData()) == 0) {
    output$sliderDate <- renderUI({ NULL })
  } else {
    output$sliderDate <- renderUI({
      sliderInput("datumrange", "Date range", min = min(allData()$date), 
                  max = max(allData()$date), value = range(allData()$date), 
                  step = 1)
    })
  }
})

# Display animals deemed as offspring
observe({
  picks <- wolfPicks()
  sibs <- fOffs()
  if (nrow(sibs) == 0) {
    output$offspring <- renderUI({ NULL })
  } else {
    output$offspring <- renderUI({
      selectInput("offspring", "Offspring", multiple = TRUE, 
                  choices = sort(sibs$reference_sample))
    })
  }
})

# If familial/cluster data is available, create a menu which 
# offers to filters out only animals from selected cluster.
observe({
  xy <- inputFileParentage()
  if ((nrow(xy) > 0) & (length(unique(xy$cluster)) > 1)) {
    output$cluster <- renderUI({
      selectInput("cluster", "Cluster/Family", multiple = FALSE, 
                  choices = c("All clusters" = "all", sort(unique(xy$cluster))))
    })
  } else {
    output$cluster <- renderUI({NULL})
  }
})

observe({
  if(!is.null(input$cluster) && input$cluster != "all") {
    output$pedig.plot <- renderUI({
      checkboxInput(inputId = "plot.pedigree", label = "Plot pedigree", value = FALSE)
    })
  } else {
    output$pedig.plot <- renderUI({NULL})
  }
})
