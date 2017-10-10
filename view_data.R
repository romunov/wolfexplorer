output$uploadSampleData <- renderDataTable({
  x <- inputFileSamples()
  DT::datatable(data = x[, !grepl("^id$", colnames(x))], 
                filter = "top", 
                extensions = 'Buttons',
                options = list(pageLength = 15, dom = 'Bfrtip', buttons = I('colvis')),
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
                extensions = 'Buttons',
                options = list(pageLength = 15, dom = 'Bfrtip', buttons = I('colvis')),
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
