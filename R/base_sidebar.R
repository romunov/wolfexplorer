sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Explore data", tabName = "explore", icon = icon("map-o")),
    menuItemOutput(outputId = "menu_data"),
    menuItem("Summary", tabName = "overview", icon = icon("eye")),
    menuItem("Settings", tabName = "settings", icon = icon("cogs")),
    menuItem("How-to", tabName = "howto", icon = icon("question-circle-o")),
    br(),
    uiOutput("parent_opacity"),
    uiOutput("offspring_opacity"),
    uiOutput("mcp_opacity"),
    uiOutput("dotSize"),
    uiOutput("mortality")
  )
)
