output$howto <- renderUI({
  box(solidHeader = TRUE, width = 12,
      includeMarkdown("./README.md")
  )
})
