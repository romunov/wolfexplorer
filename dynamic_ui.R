observe({
  xy <- allData()
  
  if (nrow(xy) > 0) { 
    ani <- sprintf("Animals: %s", length(unique(xy$animal)))
    sam <- sprintf("Samples: %s", nrow(xy))
  } else {
    ani <- sprintf("Animals: %s", 0)
    sam <- sprintf("Samples: %s", 0)
  }
  
  
  output$notifications <- renderMenu({
    dropdownMenu(type = "notifications", 
                 notificationItem(text = ani,
                                  icon("paw")),
                 notificationItem(text = sam, icon("flask")))
  })
})

observe({
  output$menu_data <- renderMenu({
    menuItem("Load data", tabName = "upload", icon = icon("paw"), startExpanded = TRUE, 
             menuSubItem(text = "Samples data", tabName = "data_samples"),
             menuSubItem(text = "Parentage data", tabName = "data_parentage"))
  })
})


observe({
  if (nrow(allData()) == 0) {
    output$comment <- renderUI({
      h4("Load some data first")
    })
  } else {
    output$comment <- renderUI({ NULL })
  }
})

observe({
  if (nrow(allData()) > 0) {
    output$animals <- renderUI({
      xy <- allData()
      selectInput("animals", "Select Animal", multiple = TRUE, choices = unique(xy$animal)) })
  } else {
    output$animals <- renderUI({ NULL })
  }
})

observe({
  if (nrow(allData()) == 0) {
    output$sliderDate <- renderUI({ NULL })
  } else {
    output$sliderDate <- renderUI({
      sliderInput("datumrange", "Date range", min = min(allData()$date), max = max(allData()$date),
                  value = range(allData()$date), step = 1)
    })
  }
}) 

observe({
  if (nrow(allData()) == 0) {
    output$parent_opacity <- renderUI({
      NULL    
    })
  } else {
    output$parent_opacity <- renderUI({
      sliderInput("parent_opacity", "Parent opacity", min = 0, max = 1,
                  value = 0.8, step = 0.1, dragRange = FALSE)
    })
  }
})

observe({
  if (nrow(fOffs()) == 0) {
    output$offspring_opacity <- renderUI({
      NULL
    })
  } else {
    output$offspring_opacity <- renderUI({
      sliderInput("offspring_opacity", "Offspring opacity", min = 0, max = 1,
                  value = 0.8, step = 0.1, dragRange = FALSE)
    })
  }
})

observe({
  if (nrow(allData()) == 0) {
    output$dotSize <- renderUI({ NULL })
  } else {
    output$dotSize <- renderUI({
      sliderInput("dotSize", "Marker size", min = 1, max = 50,
                  value = 5, step = 1, dragRange = FALSE)
    })
  }
})

observe({
  # If there is some input in input$animal, display this menu
  picks <- wolfPicks()
  sibs <- fOffs()
  if (nrow(sibs) == 0) {
    output$offspring <- renderUI({ NULL })
  } else {
    output$offspring <- renderUI({
      selectInput("offspring", "Offspring", multiple = TRUE, choices = sibs$animal)
    })
  }
})

observe({
  xy <- allData()
  par <- inputFileParentage()
  
  if(nrow(xy) > 0) {
    ani <- length(unique(xy$animal))
    male <- length(xy$sex[xy$sex == "M"])
    female <- length(xy$sex[xy$sex == "F"])
    clusters <- length(unique(par$cluster))
    sam <- nrow(xy)
    daterange <- paste(format(min(xy$date), "%d.%m.%Y" ), "-", format(max(xy$date), "%d.%m.%Y"), sep = " ")
  } else {
    ani <- 0
    male <- 0
    female <- 0
    clusters <- 0
    sam <- 0
    daterange <- 0
  }
  
  output$stats <- renderUI({
    fluidRow(
      infoBox(title = "Animals", value = ani, icon = icon("paw"), color = "olive", width = 3),
      infoBox(title = "Males", value = male, icon = icon("mars"), color = "light-blue", width = 3),
      infoBox(title = "Females", value = female, icon = icon("venus"), color = "orange", width = 3),
      infoBox(title = "Clusters", value = clusters, icon = icon("cubes"), color = "red", width = 3),
      infoBox(title = "Samples", value = sam, icon = icon("flask"), color = "yellow", width = 3),
      infoBox(title = "Date range", value = daterange, icon = icon("calendar"), color = "purple", width = 3)
    )
  })
})

observe({
  xy <- allData()
  par <- inputFileParentage()
  offs <- data.frame(table(c(par$mother, par$father))) # Get number of offspring per parent
  
  if(nrow(xy) > 0) {
    
    output$sps <- renderPlot({
      ggplot(xy)  +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1), 
              legend.position="none",
              axis.title = element_blank()) +
        geom_bar(aes(x = sample_type))
    })
    
    output$opp <- renderPlot({
      ggplot(na.omit(offs)) +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 90, hjust = 1), 
              legend.position="none",
              axis.title = element_blank()) +
        geom_col(aes(x = Var1, y = Freq))
    })
    
    output$graphs <- renderUI({
      fluidRow(
        box(solidHeader = TRUE, title = "Samples per sample type",
            plotOutput("sps")),
        box(solidHeader = TRUE, title = "Number of offspring per parent",
            plotOutput("opp"))
      ) 
    })
  }
})

# Create data.frame which maps color to sample type level
colors.df <- reactive({
  if (!exists("colors.df()", inherits = TRUE) & nrow(allData()) > 0) {
    st <- levels(allData()$sample_type)
    data.frame(sample_type_levels = st,
               sample_type_colors = brewer.pal(n = length(st), name = "Set1"),
               ui_name = sprintf("ui_%s", gsub(" ", "_", tolower(st))),
               stringsAsFactors = FALSE)
  } else {
    colors.df()
  }
})

observe({
  # try to find data for colors. if not found, create one
  # storage of this should be ported to a database at one point
  if (nrow(allData()) > 0) {
    # now that colors.df surely exists somewhere, let's construct a settings page from
    # all sample types
    output$settings_colors <- renderUI({
      if (FALSE) {
        tabs <- lapply(colors.df()$ui_name, FUN = function(x, cldf) {
          print(sprintf("%s: %s", x, cldf[cldf$ui_name == x, "sample_type_colors"]))
          colourInput(inputId = x,
                      label = cldf[cldf$ui_name == x, "sample_type_levels"],
                      value = cldf[cldf$ui_name == x, "sample_type_colors"],
                      palette = "limited")
        }, cldf = colors.df())
        
        # DAFUQ, why won't this show in the final result?!
        print(tabs)
        print(names(tabs))
        print(str(tabs))
        tabs
      } else {
        
      tabs <- list(colourInput(inputId = "ui_blood", label = "Blood", value = "#E41A1C"),
                   colourInput(inputId = "ui_decomposing_tissue", label = "Decomposing tissue", value = "#377EB8"))
      print(tabs)
      print(names(tabs))
      print(str(tabs))
      tabs
      }
    })
  } else {
    output$settings_colors <- renderUI({ p("Please upload sample data first.") })
  }
})

# if a new color is picked, update the data.frame
# observe({
#   if (nrow(allData()) > 0) {
#     
#     # print(input$ui_blood)
#     # print(input$ui_decomposing_tissue)
#     # print(input$ui_direct_saliva)
#     # print(input$ui_hair)
#     # print(input$ui_saliva)
#     # print(input$ui_scat)
#     # print(input$ui_tissue)
#     # print(input$ui_urine)
#     
#     # print("pred spremembo")
#     # print(colors.df())
#     # for (i in colors.df()$ui_name) {
#     #   # print(sprintf("working with %s", colors.df[colors.df$ui_name == i, "sample_type_levels"]))
#     #   current.color <- as.character(colors.df()[colors.df()$ui_name == i, "sample_type_colors"])
#     #   new.color <- as.character(input[[i]])
#     #   
#     #   # if colors do not match, update old color with new color
#     #   if (length(new.color) > 0 & !is.null(new.color)) {
#     #     print(sprintf("color changed for %s", i))
#     #     colors.df()[colors.df()$ui_name == i, "sample_type_colors"] <- new.color
#     #   }
#     # }
#   }
# })
