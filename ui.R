bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                sliderInput("datumrange", "Datum range", min(xy$time), max(xy$time),
                            value = range(xy$time), step = 1),
                uiOutput("animals"),
                uiOutput("siblings")
  )
)
