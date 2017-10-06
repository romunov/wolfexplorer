icons <- iconList(
  scat = makeIcon(iconUrl = "icons/dot.png", iconWidth = 8, iconHeight = 8),
  tissue = makeIcon(iconUrl = "icons/death.png", iconWidth = 18, iconHeight = 18),
  urine = makeIcon(iconUrl = "icons/dot.png", iconWidth = 8, iconHeight = 8),
  saliva = makeIcon(iconUrl = "icons/dot.png", iconWidth = 8, iconHeight = 8)
)

smp.types <- c("Tissue", "Decomposing Tissue", "Scat", "Saliva", "Urine", "Direct Saliva", "Blood", "Hair")
bcols <- brewer.pal(n = length(smp.types), name = "Set1")
bcols <- bcols[c(1, 1:length(bcols))]
pal <- colorFactor(palette = bcols, domain = smp.types, ordered = TRUE)
