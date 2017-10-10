# Create fake data

set.seed(357)
NIND <- 10 # number of individuals to generate
N <- 5 # number of points per individual

# min and max values
lng <- c(13.0, 16.6)
lat <- c(45.4, 46.88)
date <- as.Date(c("01.01.2010", "31.12.2017"), format = "%d.%m.%Y")
sample_type <- c("scat", "urine", "saliva", "tissue")
sex <- c("M", "F")

ind.pt <- data.frame(lat = runif(NIND, min = min(lat), max = max(lat)),
                     lng = runif(NIND, min = min(lng), max = max(lng)))

ind.pt <- split(ind.pt, f = 1:nrow(ind.pt))

xy <- sapply(ind.pt, FUN = function(x, N) {
  out <- data.frame(x = rnorm(N, mean = x$lng, sd = 0.05),
                    y = rnorm(N, mean = x$lat, sd = 0.05))
  tm <- sample(seq(from = min(date), to = max(date), by = "day"), 1)
  typ <- sample(sample_type, 5, replace = TRUE)
  sex <- sample(sex, 5, replace = TRUE)
  out$date <- tm + (1:N)
  out$sample_type <- typ
  out$sex <- sex
  out
}, N = N, simplify = FALSE)

xy <- do.call(rbind, xy)

xy$animal <- sprintf("%.3d", rep(1:NIND, each = N))
xy$sample_name <- as.character(1:nrow(xy))

offspring <- data.frame(sibling = sprintf("%.3d", 5:NIND),
                        mother = c("001", "002"),
                        father = c("003", "004"),
                        cluster = c("1", "2"))

write.table(x = xy, file = "data.csv", sep = ",", row.names = FALSE, quote = FALSE)
write.table(x = offspring, file = "offspring.csv", sep = ",", row.names = FALSE, quote = FALSE)
