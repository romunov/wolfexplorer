GKtoWGS <- function(df) {
  # Set "working" name of columns
  names(df)[grepl("x|X", names(df))] <- "x"
  names(df)[grepl("y|Y", names(df))] <- "y"
  
  # Detect if coordinates are in GK or WGS
  if (mean(nchar(as.integer(abs(df$x)))) > 3) { # If coords are in GK, convert them to WGS, otherwise let them be
    coordinates(df) <- c("x", "y")
    
    proj4string(df) <- CRS("+init=epsg:3912") # EPSG:3912
    WGS <- CRS("+init=epsg:4326") # WGS84
    converted <- spTransform(df, WGS)
    print(converted)
    df$lat <- converted$x
    df$lng <- converted$y
    as.data.frame(df)
  } else {
    names(df)[grepl("x", names(df))] <- "lat"
    names(df)[grepl("y", names(df))] <- "lng"
    df
  }
}
