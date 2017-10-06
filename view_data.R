output$uploadSampleData <- renderDataTable({
  x <- inputFileSamples()
  DT::datatable(data = x, filter = "top", options = list(pageLength = 15))
})

observe({
  x <- inputFileSamples()
  if (nrow(x) == 0) {
    output$view_samples <- renderUI({ NULL })
  } else {
    output$view_samples <- renderUI({
      dataTableOutput("uploadSampleData")
    })
  }
})

output$uploadParentageData <- renderDataTable({
  x <- inputFileParentage()
  DT::datatable(data = x, filter = "top", options = list(pageLength = 15))
})

observe({
  x <- inputFileParentage()
  if (nrow(x) == 0) {
    output$view_parentage <- renderUI({ NULL })
  } else {
    output$view_parentage <- renderUI({
      dataTableOutput("uploadParentageData")
    })
  }
})
