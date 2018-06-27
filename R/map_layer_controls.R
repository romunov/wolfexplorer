# observe({
#   # Logic for constructing which layers to offer. If there are animals selected,
#   # it will append the appropriate layer and pass it on to addLayersControl().
#   if (nrow(allData()) > 0) {
#     lyr <- "All samples"
#     
#     if (!is.null(input$animals)) {
#       lyr <- c(lyr, "Selected animals")
#       
#       if (length(input$mcp) > 0) {
#         if (input$mcp == TRUE) {
#           lyr <- c(lyr, "MCP")
#         }
#       }
#     }
#     
#     if (!is.null(input$offspring)) {
#       lyr <- c(lyr, "Offspring")
#     }
#     
#     if (!is.null(input$offspring) & length(input$mcp) > 0) {
#       lyr <- c(lyr, "Centroid connections")
#     }
#     
#     leafletProxy("map") %>%
#       addLayersControl(overlayGroups = lyr, position = "topleft")
#   }
# })
