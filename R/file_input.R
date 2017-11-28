inputFileSamples <- reactive({
  x <- input$data_samples
  if (is.null(x)) {
    data.frame(lng = NA, lat = NA, date = NA, sample_type = NA, animal = NA, sex = NA, sample_name = NA, id = NA)[0, ]
  } else {
    x <- tryCatch(fread(x$datapath, 
                        encoding = "UTF-8",
                        colClasses = c("numeric", "numeric", "character", "character", "character", "character", "character" ),
                        data.table = FALSE),
                  error = function(e) e,
                  warning = function(w) w
    )
    
    if (any(class(x) %in% c("simpleWarning", "simpleError"))) {
      alert("Input data not formatted properly. Please compare your input file to the specs.")
      x <- data.frame(lng = NA, lat = NA, date = NA, sample_type = NA, animal = NA, sex = NA, sample_name = NA, id = NA)[0, ]
      return(x)
    }
    
    validate(
      need(all(colnames(x) %in% c("x", "y", "date", "sample_type", "animal", "sex", "sample_name")), 
           "Column names not as expected.")
    )
    
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
    out <- tryCatch(fread(x$datapath, encoding = "UTF-8", 
                          colClasses = c("character", "character", "character", "character"),
                          data.table = FALSE),
                    error = function(e) e,
                    warning = function(w) w
    )
    
    if (any(class(out) %in% c("simpleWarning", "simpleError"))) {
      alert("Input data not formatted properly. Please compare your input file to the specs.")
      out <- data.frame(offspring = NA, mother = NA, father = NA, cluster = NA)[0, ]
      return(out)
    } 
    
    # if column names do not match predefined form, warn user
    validate(
      need(all(colnames(out) %in% c("offspring", "mother", "father", "cluster")),
           "Column names not as expected.")
    )
    return(out)
  }
})
