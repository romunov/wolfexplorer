#' This function assumes data are in x/y columns in Gauss-Krüger (EPSG: 3912) and converts them to
#' WGS (EPSG: 4326).
#' @param df A data.frame with at least columns x and y.
#' @author Zan Kuralt (zan.kuralt@@gmail.com)

GKtoWGS <- function(df) {
  # Set "working" name of columns
  names(df)[grepl("^x$|^X$", names(df))] <- "x"
  names(df)[grepl("^y$|^Y$", names(df))] <- "y"
  
  # Detect if coordinates are in GK or WGS
  if (mean(nchar(as.integer(abs(df$x)))) > 3) { # If coords are in GK, convert them to WGS, otherwise let them be
    coordinates(df) <- ~ x + y
    
    proj4string(df) <- CRS("+init=epsg:3912") # EPSG:3912
    WGS <- CRS("+init=epsg:4326") # WGS84
    converted <- spTransform(df, WGS)
    
    df$lng <- converted$x
    df$lat <- converted$y
    df <- as.data.frame(df)
    df
  } else {
    names(df)[grepl("^x$", names(df))] <- "lng"
    names(df)[grepl("^y$", names(df))] <- "lat"
    df
  }
}


#' Create popup for samples.
populatePopup <- function(x) {
  out <- sprintf("<dl>
                   <dt>animal: %s</dt>
                   <dt>date: %s</dt>
                   <dt>sex: %s</dt>
                   <dt>sample type: %s</dt>
                 </dl>",
                 x$animal,
                 x$date,
                 x$sex,
                 x$sample_type)
  out
}

#' Set custom dropdown menu text
customSentence <- function(numItems, type) {
  paste("Currently displaying")
}

#' Function to call in place of dropdownMenu
dropdownMenuCustom <- function (..., type = c("messages", "notifications", "tasks"),
                                badgeStatus = "primary", icon = NULL, .list = NULL, customSentence = customSentence)
{
  type <- match.arg(type)
  if (!is.null(badgeStatus)) shinydashboard:::validateStatus(badgeStatus)
  items <- c(list(...), .list)
  lapply(items, shinydashboard:::tagAssert, type = "li")
  dropdownClass <- paste0("dropdown ", type, "-menu")
  if (is.null(icon)) {
    icon <- switch(type, messages = shiny::icon("envelope"),
                   notifications = shiny::icon("warning"), tasks = shiny::icon("tasks"))
  }
  numItems <- length(items)
  if (is.null(badgeStatus)) {
    badge <- NULL
  }
  else {
    badge <- span(class = paste0("label label-", badgeStatus),
                  numItems)
  }
  tags$li(
    class = dropdownClass,
    a(
      href = "#",
      class = "dropdown-toggle",
      `data-toggle` = "dropdown",
      icon,
      badge
    ),
    tags$ul(
      class = "dropdown-menu",
      tags$li(
        class = "header",
        customSentence(numItems, type)
      ),
      tags$li(
        tags$ul(class = "menu", items)
      )
    )
  )
}
