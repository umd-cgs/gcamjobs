# Build internal Package Data

# Load Libraries
library(tibble);library(dplyr); library(data.table); library(usethis)

saveDataFiles_folder <- paste0(getwd(),"/extras")

# IRENA.tech.mapping
IRENA.tech.mapping <- read.csv(paste0(saveDataFiles_folder,"/IRENA.tech.mapping.csv"), check.names = FALSE)%>%
  tibble::as_tibble()
use_data(IRENA.tech.mapping, version=3, overwrite=T)

