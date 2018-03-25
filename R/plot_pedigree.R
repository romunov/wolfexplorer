observeEvent(input$plot.pedigree, {
  samples <- inputFileSamples()
  relations <- inputFileParentage()
  cluster <- input$cluster
  
  family <- fillParentsAndSexAndStatus(samples, relations, cluster)
  
  # tole je testno, ki odstrani le enega znanega starša, v primeru, da nista znana ali neznana oba.
  # Ne vem kako je Bine to reševal.
  for (i in 1:nrow(family)) {
    if (sum(family$mother[i] == "" | family$father[i] == "") == 1) {
      family$mother[i] <- ""
      family$father[i] <- ""
    }
  }
  
  # izdelaj pedigree
  pdgr <- pedigree(id = family$offspring, 
                   dadid = family$father, 
                   momid = family$mother, 
                   sex = family$sex, 
                   status = family$status,
                   missid = "")
  
  output$pedigree.plot <- renderPlot({
    plot(pdgr)
  })
  
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