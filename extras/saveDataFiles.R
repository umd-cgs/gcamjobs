# Build internal Package Data

# Load Libraries
library(tibble);library(dplyr); library(data.table); library(usethis)

saveDataFiles_folder <- paste0(getwd(),"/extras")

# IRENA_capacity
IRENA_capacity <- data.table::fread(paste0(saveDataFiles_folder,"/IRENA_capacity.csv"))%>%
  tibble::as_tibble()
use_data(IRENA_capacity, version=3, overwrite=T)
