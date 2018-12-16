library(RSQLite)

db <- dbConnect(RSQLite::SQLite(), './db/wolfexplorer.sqlite')

data.sample <- "./data/sample_wolf_data.txt"
data.parentage <- "./data/sample_wolf_parentage.txt"

if (file.exists(data.sample)) {
  # TODO: We may want to implement some sanity checks (e.g. check proper column names, types).
  smp <- read.table(data.sample, header = TRUE, sep = ",")
  dbWriteTable(conn = db, name = "samples", smp)
} else {
  dbWriteTable(conn = db, name = "samples",
               data.frame(x = as.numeric(NA),
                          y = as.numeric(NA),
                          date = as.character(NA),
                          sample_type = as.character(NA),
                          animal = as.character(NA),
                          sex = as.character(NA),
                          sample_name = as.character(NA),
                          reference_sample = as.character(NA))[0, ])
}

if (file.exists(data.parentage)) {
  # TODO: We may want to implement some sanity checks (e.g. check proper column names, types).
  prt <- read.table(data.parentage, header = TRUE, sep = ",", comment.char = "")
  dbWriteTable(conn = db, name = "parentage", prt)
} else {
  # If input files are not present, add empty table.
  dbWriteTable(conn = db, name = "parentage", 
               data.frame(offsprint = as.character(NA),
                          mother = as.character(NA),
                          father = as.character(NA),
                          cluster = as.numeric(NA))[0, ])
}

