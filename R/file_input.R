inputFileSamples <- reactive({
  xy <- dbReadTable(conn = db, "samples")
  # x         y       date sample_type animal sex sample_name reference_sample
  # 1   415290.5  48492.58 2010-04-23      Saliva    657   M     AH.03MT          AH.03MT
  # 2   439351.3  44444.31 2014-12-22      Saliva    657   M     EX.1JKT          AH.03MT
  # 3   445348.9  44420.60 2014-12-15      Saliva    658   M     EX.1JJ1          AL.05PH
  
  validate(
    need(all(colnames(xy) %in% c("x", "y", "date", "sample_type", "animal", "sex", 
                                 "sample_name", "reference_sample")), 
         "Column names not as expected.")
  )
  
  if (nrow(xy) > 0) {
    xy <- GKtoWGS(xy)
    xy$date <- as.Date(xy$date, format = "%Y-%m-%d")  # sqlite can't handle dates properly
    xy$id <- 1:nrow(xy)
  }
  
  xy
})

inputFileParentage <- reactive({
  xy <- dbReadTable(conn = db, "parentage")
  # offspring  mother  father cluster
  # 1     M2122 AU.0AEF AH.03MT       2
  # 2     M0PLL      #1   M1J4C       2
  # 3     M110M      #2      *3       3
  # 4     M1H52   M1HXJ AL.0611       2
  validate(
    need(all(colnames(xy) %in% c("offspring", "mother", "father", "cluster")),
         "Column names not as expected.")
  )
  
  xy
})
