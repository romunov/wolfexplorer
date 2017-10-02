bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                sliderInput("datumrange", "Datum range", min(xy$time), max(xy$time),
                            value = range(xy$time), step = 1),
                selectInput("animals", "Select Animal", multiple = TRUE, choices = unique(xy$animal),
                            selected = "001")
  )
)
