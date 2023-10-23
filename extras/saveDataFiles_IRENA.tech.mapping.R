# Build internal Package Data

# Load Libraries
library(tibble);library(dplyr); library(data.table); library(usethis)

saveDataFiles_folder <- paste0(getwd(),"/extras")

# RE_ratio_2020
RE_ratio_2020 <- read.csv(paste0(saveDataFiles_folder,"/RE_Ratio_2020.csv"), check.names = FALSE)%>%
  tibble::as_tibble()
use_data(RE_ratio_2020, version=3, overwrite=T)

