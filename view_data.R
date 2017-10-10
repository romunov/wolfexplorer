output$uploadSampleData <- renderDataTable({
  x <- inputFileSamples()
  DT::datatable(data = x[, !grepl("^id$", colnames(x))], 
                filter = "top", 
                options = list(pageLength = 15), 
                selection = 'single',
                rownames = FALSE)
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
  DT::datatable(data = x, 
                filter = "top", 
                options = list(pageLength = 15),
                rownames = FALSE)
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
