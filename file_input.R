inputFileSamples <- reactive({
  x <- input$data_samples
  if (is.null(x)) {
    data.frame(lng = NA, lat = NA, date = NA, sample_type = NA, animal = NA, sex = NA, sample_name = NA, id = NA)[0, ]
  } else {
    x <- fread(x$datapath, 
               encoding = "UTF-8",
                  colClasses = c("numeric", "numeric", "character", "character", "character", "character", "character" ),
               data.table = FALSE)
    x <- GKtoWGS(x)
    x$date <- as.Date(x$date, format = "%Y-%m-%d")
    x$id <- 1:nrow(x)
    x
  }
})

inputFileParentage <- reactive({
  x <- input$data_parentage
  if (is.null(x)) {
    data.frame(offspring = NA, mother = NA, father = NA, cluster = NA)[0, ]
  } else {
    fread(x$datapath, encoding = "UTF-8", 
          colClasses = c("character", "character", "character", "character"),
          data.table = FALSE)
  }
})
