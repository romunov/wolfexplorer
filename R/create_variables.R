PS <- reactive({
  input$dotSize ## Point size
})

# All sample data
allData <- reactive({
  xy <- inputFileSamples()
})

# Subset data based on input from slider
fData <- reactive({
  xy <- inputFileSamples()
  if (nrow(xy) > 0) {
    # make available only animals from selected cluster
    getklus <- getCluster()
    if (!is.null(getklus)) {
      xy <- xy[xy$reference_sample %in% getklus, ]
    }
    
    # and select by datum range
    xy[(xy$date >= input$datumrange[1] & xy$date <= input$datumrange[2]), ]
  } else {
    xy[0, ]
  }
})

wolfPicks <- reactive({
  xy <- fData()
  if (nrow(xy) > 0 & length(input$animals) > 0) {
    xy[(xy$reference_sample %in% input$animals), ]
  } else {
    xy[0, ]
  }
})

mortality <- reactive({
  xy <- allData()
  if (nrow(xy) > 0) {
    xy[xy$sample_type %in% c("Tissue", "Decomposing tissue"), ]
  } else {
    xy[0, ]
  }
})

# Filter out offspring from data.
fOffs <- reactive({
  xy <- fData()
  x <- unique(wolfPicks()$reference_sample)
  offspring <- inputFileParentage()
  
  if (nrow(offspring) > 0) {
    offs <- offspring[offspring$mother %in% x | offspring$father %in% x, "offspring"]
    xy[(xy$reference_sample %in% offs) 
       & (xy$date >= input$datumrange[1] & xy$date <= input$datumrange[2]), ]
  } else {
    offspring
  }
})

# Retrieve information about cluster, if offspring (heritage) data exists.
getCluster <- reactive({
  
  kls <- inputFileParentage()
  xy <- allData()
  if(is.null(input$cluster)){
    return(NULL)
  }
  if (input$cluster == "all") {
    return(xy[, "reference_sample"])
  } else {
    # select only entries with animals from selected clusters/families
    kls <- kls[kls$cluster %in% input$cluster, ]
    
    # and return only animal names of animals from selected clusters
    out <- xy[
      xy$reference_sample %in% kls$offspring | 
        xy$reference_sample %in% kls$mother | 
        xy$reference_sample %in% kls$father, ]
    return(out[, "reference_sample"])
  }
})
