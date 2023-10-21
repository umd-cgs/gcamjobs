# Build internal Package Data

# Load Libraries
library(tibble);library(dplyr); library(data.table); library(usethis)

saveDataFiles_folder <- paste0(getwd(),"/extras")

# gcam_region_id
gcam_region_id <- read.csv(paste0(saveDataFiles_folder,"/iso_GCAM_regID.csv"), check.names = FALSE)%>%
  tibble::as_tibble()
use_data(gcam_region_id, version=3, overwrite=T)
