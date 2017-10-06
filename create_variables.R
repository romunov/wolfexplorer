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
    xy[(xy$date >= input$datumrange[1] & xy$date <= input$datumrange[2]), ]
  } else {
    xy[0, ]
  }
})

wolfPicks <- reactive({
  xy <- fData()
  if (nrow(xy) > 0 & length(input$animals) > 0) {
    xy[(xy$animal %in% input$animals), ]
  } else {
    xy[0, ]
  }
})

# Filter out offspring from data
fOffs <- reactive({
  xy <- fData()
  x <- wolfPicks()$animal
  offspring <- inputFileParentage()
  if (nrow(offspring) > 0) {
    offs <- offspring[offspring$mother %in% x | offspring$father %in% x, "sibling"]
    xy[(xy$animal %in% offs) & (xy$date >= input$datumrange[1] & xy$date <= input$datumrange[2]), ]
  } else {
    offspring
  }
})
