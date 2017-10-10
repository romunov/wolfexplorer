sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Explore data", tabName = "explore", icon = icon("map-o")),
    menuItemOutput(outputId = "menu_data"),
    menuItem("Dataset overview", tabName = "overview", icon = icon("eye")),
    menuItem("Settings", tabName = "settings", icon = icon("cogs")),
    br(),
    uiOutput("parent_opacity"),
    uiOutput("offspring_opacity"),
    uiOutput("dotSize"),
    uiOutput("mortality")
  )
)
