# Render sidebar controls (opacity, marker size, mortality switch).
observe({
  if (nrow(allData()) > 0) {
    output$mortality <- renderUI({
      checkboxInput(inputId = "muerto", label = "Show mortalities", value = FALSE) })
  } else {
    output$mortality <- renderUI({ NULL })
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
  if (any(is.null(input$mcp), input$mcp == FALSE)) {
    output$mcp_opacity <- renderUI({
      NULL    
    })
  } else {
    output$mcp_opacity <- renderUI({
      sliderInput("mcp_opacity", "MCP opacity", min = 0, max = 1,
                  value = 0.2, step = 0.1, dragRange = FALSE)
    })
  }
})
