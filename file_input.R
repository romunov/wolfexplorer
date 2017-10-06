inputFileSamples <- reactive({
  x <- input$data_samples
  if (is.null(x)) {
    data.frame(lng = NA, lat = NA, date = NA, sample_type = NA, animal = NA, sex = NA, sample_name = NA, id = NA)[0, ]
  } else {
    read.csv(x$datapath, header = TRUE, sep = ",",
             encoding = "UTF-8", stringsAsFactors = FALSE, 
             colClasses = c("numeric", "numeric", "Date", "character", "character", "character", "character" ))
  }
})

inputFileParentage <- reactive({
  x <- input$data_parentage
  if (is.null(x)) {
    data.frame(offspring = NA, mother = NA, father = NA, cluster = NA)[0, ]
  } else {
    read.csv(x$datapath, header = TRUE, sep = ",",
             encoding = "UTF-8", stringsAsFactors = FALSE,
             colClasses = "character")
  }
})
