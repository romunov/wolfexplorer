icons <- iconList(
  scat = makeIcon(iconUrl = "icons/dot.png", iconWidth = 8, iconHeight = 8),
  tissue = makeIcon(iconUrl = "icons/death.png", iconWidth = 18, iconHeight = 18),
  urine = makeIcon(iconUrl = "icons/dot.png", iconWidth = 8, iconHeight = 8),
  saliva = makeIcon(iconUrl = "icons/dot.png", iconWidth = 8, iconHeight = 8)
)

bcols <- brewer.pal(n = 7, name = "Set1")
pal <- colorFactor(palette = bcols, domain = c("Tissue", "Scat", "Saliva", "Urine", "Direct Saliva", "Blood", "Hair"),
                   ordered = TRUE)
