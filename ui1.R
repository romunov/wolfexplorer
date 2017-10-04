bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                sliderInput("datumrange", "Datum range", min = min(xy$time), max = max(xy$time),
                            value = range(xy$time), step = 1),
                uiOutput("animals"),
                uiOutput("siblings")
  ),
  absolutePanel(bottom = 10, right = 10,
                sliderInput("opacityrange", "Line/Point opacity", min = 0, max = 1,
                            value = 0.7, step = 0.1, dragRange = FALSE, width = "70%"))
)
