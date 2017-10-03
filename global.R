library(shiny)
library(leaflet)
library(RColorBrewer)

source("generate_fake_data.R")

PS <- 5 ## Point size

icons <- iconList(
  scat = makeIcon(iconUrl = "icons/dot.png", iconWidth = 8, iconHeight = 8),
  tissue = makeIcon(iconUrl = "icons/death.png", iconWidth = 18, iconHeight = 18),
  urine = makeIcon(iconUrl = "icons/dot.png", iconWidth = 8, iconHeight = 8),
  saliva = makeIcon(iconUrl = "icons/dot.png", iconWidth = 8, iconHeight = 8)
)
