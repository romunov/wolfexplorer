inputFileSamples <- reactive({
  x <- input$data_samples
  if (is.null(x)) {
    data.frame(lng = NA, lat = NA, time = NA, type = NA, animal = NA, id = NA)[0, ]
  } else {
    read.csv(x$datapath, header = TRUE, sep = ",",
             encoding = "UTF-8", stringsAsFactors = FALSE, 
             colClasses = c("numeric", "numeric", "Date", "character", "character"))
  }
})

inputFileParentage <- reactive({
  x <- input$data_parentage
  if (is.null(x)) {
    data.frame(sibling = NA, mother = NA, father = NA)[0, ]
  } else {
    read.csv(x$datapath, header = TRUE, sep = ",",
             encoding = "UTF-8", stringsAsFactors = FALSE,
             colClasses = "character")
  }
})
