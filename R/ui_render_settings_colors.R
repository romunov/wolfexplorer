# Create data.frame which maps color to sample type level
colors.df <- reactiveValues()
colors.df$mapping <- data.frame(sample_type_levels = numeric(0),
                                sample_type_colors = numeric(0),
                                ui_name = numeric(0), stringsAsFactors = FALSE)
observe({
  if (nrow(colors.df$mapping) == 0 & nrow(allData()) > 0) {
    st <- unique(allData()$sample_type)
    colors.df$mapping <- data.frame(sample_type_levels = st,
                                    sample_type_colors = brewer.pal(n = length(st), name = "Set1"),
                                    ui_name = sprintf("ui_%s", gsub(" ", "_", tolower(st))),
                                    stringsAsFactors = FALSE)
  } 
})

# Create a settings menu for colors
observe({
  if (nrow(allData()) > 0) {
    output$settings_colors <- renderUI({
      mapping <- colors.df$mapping
      mapping <- split(mapping, f = 1:nrow(mapping))
      
      tabs <- sapply(mapping, FUN = function(x) {
        colourInput(inputId = x["ui_name"],
                    label = x["sample_type_levels"],
                    value = x["sample_type_colors"],
                    palette = "square")
      }, simplify = FALSE)
      tabs
    })
  } else {
    output$settings_colors <- renderUI({ p("Please upload sample data first.") })
  }
})

# if a new color is picked, update the data.frame
observe({
  if (nrow(allData()) > 0) {
    for (i in colors.df$mapping$ui_name) {
      # print(sprintf("working with %s", colors.df[colors.df$ui_name == i, "sample_type_levels"]))
      new.color <- input[[i]]
      if (!is.null(new.color)) {
        current.color <- as.character(colors.df$mapping[colors.df$mapping$ui_name == i, "sample_type_colors"])
        if (new.color != current.color) {
          # if colors do not match, update old color with new color
          colors.df$mapping[colors.df$mapping$ui_name == i, "sample_type_colors"] <- new.color
        }
      }
    }
  }
})
