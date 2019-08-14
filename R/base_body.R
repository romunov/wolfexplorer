body <- dashboardBody(
  tags$style(type = "text/css", "#map {height: 100% !important;}"),
  tabItems(
    tabItem(tabName = "explore",
            div(class="outer",
                tags$head(
                  # Include our custom CSS
                  includeCSS("./css/styles.css")
                ),
                leafletOutput("map"),
                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                              width = 330, height = "auto",
                              uiOutput("comment"),
                              uiOutput("sliderDate"),
                              uiOutput("cluster"),
                              uiOutput("pedig.plot"),
                              br(),
                              uiOutput("animals"),
                              uiOutput("offspring"),
                              uiOutput("mcp")
                ),
                uiOutput("pedigree.panel") 
            )
    ),
    tabItem(tabName = "data_samples",
            uiOutput("view_samples")
    ),
    tabItem(tabName = "data_parentage",
            uiOutput("view_parentage")
    ),
    tabItem(tabName = "overview",
            uiOutput("stats"),
            fluidRow(
            uiOutput("table_samples"),
            uiOutput("table_offs"),
            uiOutput("table_clust")
            )
    ),
    tabItem(tabName = "settings",
            fluidRow(
              tabBox(side = "left", selected = "Color settings", width = 12,
                     tabPanel("General", "Not implemented yet."),
                     tabPanel("Color settings", uiOutput("settings_colors"))
              )
            )
    ),
    tabItem(tabName = "howto",
            fluidPage(
            uiOutput("howto"))
            )
  )
)
