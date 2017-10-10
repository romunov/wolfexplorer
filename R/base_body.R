body <- dashboardBody(
  tags$style(type = "text/css", "#map {height: 100% !important;}"),
  tabItems(
    tabItem(tabName = "explore",
            div(class="outer",
                tags$head(
                  # Include our custom CSS
                  includeCSS("./css/styles.css")
                  # includeScript("gomap.js")
                ),
                leafletOutput("map"),
                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                              width = 330, height = "auto",
                              uiOutput("comment"),
                              uiOutput("sliderDate"),
                              uiOutput("animals"),
                              uiOutput("offspring")
                )
            )
    ),
    tabItem(tabName = "data_samples",
            fluidRow(
              box(solidHeader = TRUE, collapsible = TRUE, title = "Upload samples data",
                  fileInput(inputId = "data_samples", 
                            label = "Upload dataset",
                            buttonLabel = "Select data",
                            accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv"))),
              h4("Upload parentage data for full functionality")),
            br(),
            br(),
            uiOutput("view_samples")
    ),
    tabItem(tabName = "data_parentage",
            box(solidHeader = TRUE, collapsible = TRUE, title = "Upload parentage / colony data",
                fileInput(inputId = "data_parentage", 
                          label = "Upload dataset",
                          buttonLabel = "Select data",
                          accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv"))),
            br(),
            br(),
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
                     tabPanel("General", "some general text"),
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
