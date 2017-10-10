# Statistics page
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
