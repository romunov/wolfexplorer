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
  out <- sprintf("<dt>Animal: %s</dt>
                   <dt>Date: %s</dt>
                   <dt>Sex: %s</dt>
                   <dt>Known parents: %s</dt>
                   <dt>Sample type: %s</dt>",
                 x$animal,
                 x$date,
                 x$sex,
                 x$label,
                 x$sample_type)
  out
}


# Create popups for polygons.
populatePolygonPopup <- function(x) {
  out <- htmltools::HTML(sprintf("
                   <dt>Animal: %s</dt>
                   <dt>First record: %s</dt>
                   <dt>Last record: %s</dt>
                   <dt>Sex: %s</dt>
                   <dt>Known parents: %s</dt>
                   <dt>Num. of samples: %s</dt>",
                                 unique(x$animal),
                                 min(x$date),
                                 max(x$date),
                                 unique(x$sex),
                                 unique(x$label),
                                 nrow(x))
  )
  out
}


# Add parentage information to samples.
addParentageData <- function(xy, parents) {
  if (nrow(xy) > 0) {
    if (nrow(parents) > 0) {
      parents[parents$mother == "", "mother"] <- "Unknown"
      parents[parents$father == "", "father"] <- "Unknown"
      
      xy <- merge(xy, parents, by.x = "animal", by.y = "offspring", all.x = TRUE)
      xy$label <- sprintf("M: %s F: %s", xy$mother, xy$father)
    } else {
      xy$label <- "M: No data F: No data"
    }
  } else {
    # add an empty column if no animals have been selected yet
    xy <- cbind(xy, data.frame(label = "")[0, , drop = FALSE]) 
  }
  xy
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

#' Function computes the subset of points which lie on the convex hull of the 
#' set of points specified. If there is only one point, it creates a buffer 
#' around it. If there are two points it creates an ellipse buffer based on 
#' line connecting those points. If there are three or more points it 
#' creates a standard mcp polygon.
calChull <- function(x) {
  if (nrow(x) == 1) {
    coordinates(x) <- ~ lng + lat
    point <- SpatialPoints(x)
    
    # convert to UTM to have buffer in sensible units
    initcrs <- CRS("+init=epsg:4326")
    proj4string(point) <- initcrs
    point <- spTransform(point, CRSobj = CRS("+init=epsg:3912"))
    mcp <- gBuffer(point, width = 1000) # buffer of 1 km
    mcp <- spTransform(mcp, CRSobj = initcrs)
    return(mcp)
  }
  
  if (nrow(x) == 2) {
    initcrs <- CRS("+init=epsg:4326")
    
    coordinates(x) <- ~ lng + lat
    line <- Line(x)
    lines <- Lines(slinelist = list(line), ID = "1")
    s.line <- SpatialLines(LinesList = list(lines))
    
    # convert to UTM to have buffer in sensible units
    proj4string(s.line) <- initcrs
    s.line <- spTransform(s.line, CRSobj = CRS("+init=epsg:3912"))
    mcp <- gBuffer(s.line, width = 1000) # buffer of 1 km
    mcp <- spTransform(mcp, CRSobj = initcrs)
    
    return(mcp)
  }
  
  if (nrow(x) > 2) {
    mcp <- x[chull(x$lng, x$lat), ]
    coordinates(mcp) <- ~ lng + lat
    suppressWarnings(mcp <- SpatialPolygons(list(Polygons(list(Polygon(mcp)), ID = 1))))
    return(mcp)
  }
}


#' Function checks that all animals from selected cluster have known parents.
#' In case of missing parents it fills them with "", which enables kinship2 package
#' to plot the pedigree. It also adds information about sex and status to the dataset.
#' @param samples A data.frame with samples data
#' @param data A data.frame with parentage data
#' @param cluster Selected cluster


fillSexAndStatus <- function(samples, data, cluster) {
  
  # browser()
  
  samples$sex <- as.character(samples$sex)
  
  # kinship2 needs sex data in that form.
  samples$sex[samples$sex == "M"] <- "male"
  samples$sex[samples$sex == "F"] <- "female"
  samples$sex[samples$sex == "NA"] <- "unknown"

  fam <- data[data$cluster == cluster, ] # subset data by cluster

  # for (i in 1:nrow(fam)) {
  #   if (nchar(fam$mother[i]) == 0) {
  #     virtual.mother <- paste("UM", i, sep = "")
  #     fam$mother[i] <- virtual.mother
  #     add.virtual.mother <- c(virtual.mother, "", "", cluster)
  #     fam <- rbind(fam, add.virtual.mother)
  #   }
  #   if (nchar(fam$father[i]) == 0) {
  #     virtual.father <- paste("UF", i, sep = "")
  #     fam$father[i] <- virtual.father
  #     add.virtual.father <- c(virtual.father, "", "", cluster)
  #     fam <- rbind(fam, add.virtual.father)
  #   }
  # }


  members <- na.omit(unique(unlist(fam[ , c("offspring", "father", "mother")]))) # find all cluster members
  members <- members[nchar(members) > 0]

  no.parents <- members[!(members %in% fam$offspring)] # find members without known parents
  
  # # print(paste("Found", length(no.parents), "animals without known parents.", sep = " "))

  # fill empty parents to those members
  for (i in no.parents) {
    add.parents <- c(i, "", "", cluster)
    fam <- rbind(fam, add.parents)
  }

  # print(paste("Family has", nrow(fam), "members.", sep = " "))

  # v podatkih o vzorcih poišči podatke o spolu članov družine
  sex_data <- unique(samples[samples$reference_sample %in% members, c("reference_sample", "sex")])

  dead_animals <- samples[samples$sample_type %in% c("Decomposing Tissue", "Tissue") &
                            samples$reference_sample %in% members, c("reference_sample")]

  # pridruži podatke o spolu
  data <- merge(x = fam, y = sex_data, by.x = "offspring", by.y = "reference_sample", all = TRUE)

  data$sex[grep(pattern = "[*]", x = data$offspring, ignore.case = TRUE)] <- "male"
  data$sex[grep(pattern = "[#]", x = data$offspring, ignore.case = TRUE)] <- "female"

  data$cluster <- cluster

  data$status <- 0
  data$status[data$offspring %in% dead_animals] <- 1
  # print(paste(length(dead_animals), "known dead animal(s) in the family.", sep = " "))

  data
}
