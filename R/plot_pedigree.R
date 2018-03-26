observeEvent(input$plot.pedigree, {
  samples <- inputFileSamples()
  relations <- inputFileParentage()
  cluster <- input$cluster
  
  family <- fillParentsAndSexAndStatus(samples, relations, cluster)
  
  # izdelaj pedigree
  pdgr <- pedigree(id = family$offspring, 
                   dadid = family$father, 
                   momid = family$mother, 
                   sex = family$sex, 
                   status = family$status,
                   missid = "")
  
  output$pedigree.plot <- renderPlot({
    plot(pdgr, cex = 0.6)
  })
  
  # this answer helped with collapsible panel - https://stackoverflow.com/questions/35175167/collapse-absolutepanel-in-shiny/35175847
  
  output$pedigree.panel <- renderUI({
    absolutePanel(id = "pedigree", class = "panel panel-default", fixed = TRUE,
                  draggable = FALSE, top = "auto", left = 250, right = "auto", bottom = 15, 
                  width = 800, height = "auto",
                  HTML('<button data-toggle="collapse" data-target="#demo">Show / hide pedigree</button>'),
                  tags$div(id = "demo", class="collapse in",
                           plotOutput("pedigree.plot")
                  )
    )
  })
})
