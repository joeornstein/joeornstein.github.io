#Converts pdfs to png images.
#Thanks to Alexander Coppock for the code!
#Last Updated August 6, 2018 by Joe Ornstein

rm(list = ls())
setwd("~/GitHub/joeornstein.github.io/")
library(magick)
library(magrittr)

convertPDFtoPNG <- function(path.name) {
  files <- list.files(path = path.name, pattern = ".pdf")
  
  file_names <- gsub(pattern = ".pdf",
                     replacement = "",
                     x = files)
  
  for (i in 1:length(files)) {
    image_read_pdf(paste0(path.name, files[i]), density = 500) %>%
      image_scale("1000") %>%
      image_crop("1000x1000") %>%
      image_convert(format = "png") %>%
      image_write(paste0(path.name, file_names[i], ".png"))
    print(i)
  }
}

start <- Sys.time()
#Papers
convertPDFtoPNG("papers/")
#Syllabi
convertPDFtoPNG("teaching/")
#CV
convertPDFtoPNG("CV/")
stop <- Sys.time()
stop - start


#Scale Headshot
image_read("images/ornstein-head.jpg") %>%
  image_scale("1000") %>%
  image_crop("1000x1000") %>%
  image_convert(format = "png") %>%
  image_write("images/ornstein-head-scaled.png")


