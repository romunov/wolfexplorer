observe({
  
  if (is.null(input$plot.pedigree)) return(NULL)
  if (input$plot.pedigree == TRUE && input$cluster != "all") {
    
    
    samples <- inputFileSamples()
    relations <- inputFileParentage()
    cluster <- input$cluster
    
    family <- fillSexAndStatus(samples, relations, cluster)
    
    # izdelaj pedigree
    pdgr <- pedigree(id = family$offspring, 
                     dadid = family$father, 
                     momid = family$mother, 
                     sex = family$sex, 
                     status = family$status,
                     missid = "0")
    
    output$pedigree.plot <- renderPlot({
      plot(pdgr, 
           cex = 1, 
           srt = 90,
           col = "#31a354")
    })
    
    # this answer helped with collapsible panel
    # https://stackoverflow.com/questions/35175167/collapse-absolutepanel-in-shiny/35175847
    
    output$pedigree.panel <- renderUI({
      absolutePanel(id = "pedigree", class = "panel panel-default", fixed = TRUE,
                    draggable = FALSE, top = "auto", left = 250, right = "auto", bottom = 10, 
                    width = 800, height = "auto",
                    HTML('<button data-toggle="collapse" data-target="#demo">Collapse</button>'),
                    tags$div(id = "demo", class="collapse in",
                             plotOutput("pedigree.plot")
                    )
      )
    })
  }
  if (input$plot.pedigree == FALSE) {
    output$pedigree.panel <- renderUI({ NULL })
    }
  if (input$cluster == "all") {
    output$pedigree.panel <- renderUI({ NULL })
    }
})

