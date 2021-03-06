# Statistics page
observe({
  xy <- fData()
  df <- xy[!duplicated(xy$animal), ]
  par <- inputFileParentage()
  
  if(nrow(xy) > 0) {
    ani <- length(unique(xy$reference_sample))
    male <- length(df$sex[df$sex == "M"])
    female <- length(df$sex[df$sex == "F"])
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
      infoBox(title = "Animals", value = ani, icon = icon("paw"), color = "olive", width = 4),
      infoBox(title = "Males", value = male, icon = icon("mars"), color = "light-blue", width = 4),
      infoBox(title = "Females", value = female, icon = icon("venus"), color = "maroon", width = 4),
      infoBox(title = "Samples", value = sam, icon = icon("flask"), color = "yellow", width = 4),
      infoBox(title = "Clusters", value = clusters, icon = icon("cubes"), color = "red", width = 4),
      infoBox(title = "Date range", value = daterange, icon = icon("calendar"), color = "purple", width = 4)
    )
  })
})

observe({
  xy <- fData()
  sam_typ <- data.frame(table(xy$sample_type))
  par <- inputFileParentage()
  par.t <- gather(par, -offspring, key = parent, value = value)
  par.t$value <- gsub("^$", NA, par.t$value)
  par.t <- par.t[par.t$parent != "cluster", ]
  par.tidy <- na.omit(par.t)
  par.tidy <- par.tidy[, c("offspring", "value")]
  offs <- data.frame(count(par.tidy, "value")) # Get number of offspring per parent
  clust <- data.frame(count(par, "cluster"))
  
  
  if (nrow(allData()) > 0) {
    output$sps <- renderDataTable({
     sam_typ
      colnames(sam_typ) <- c("Sample type", "Count")
      DT::datatable(sam_typ, rownames = FALSE)
    })
    
    output$table_samples <- renderUI({
      box(solidHeader = TRUE, title = "Samples per sample type", width = 4,
          dataTableOutput("sps"))
    })
  }
  
  if (nrow(par) > 0) {
    output$opp <- renderDataTable({
      offs
      colnames(offs) <- c("Animal", "Offspring count")
      DT::datatable(offs, rownames = FALSE)
    })
    
    output$clust <- renderDataTable({
      clust
      colnames(clust) <- c("Cluster", "Animal count")
      DT::datatable(clust, rownames = FALSE)
    })
    
    output$table_offs <- renderUI({
      box(solidHeader = TRUE, title = "Number of offspring per parent", width = 4,
          dataTableOutput("opp"))
    })
    
    output$table_clust <- renderUI({
      box(solidHeader = TRUE, title = "Number of individuals per cluster", width = 4,
          dataTableOutput("clust"))
    })
  } 
})
