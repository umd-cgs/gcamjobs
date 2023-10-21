# Build internal Package Data

# Load Libraries
library(tibble);library(dplyr); library(data.table); library(usethis)

saveDataFiles_folder <- paste0(getwd(),"/extras")

# gcam_region_name
gcam_region_name <- read.csv(paste0(saveDataFiles_folder,"/GCAM_region_names.csv"), check.names = FALSE)%>%
  tibble::as_tibble()
use_data(gcam_region_name, version=3, overwrite=T)
