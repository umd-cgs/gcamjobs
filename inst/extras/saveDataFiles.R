# Load Libraries
library(tibble);library(dplyr); library(data.table); library(usethis)

saveDataFiles_folder <- paste0(getwd(),"/inst/extras"); saveDataFiles_folder

# gcam_region_id
gcam_region_id <- read.csv(paste0(saveDataFiles_folder,"/iso_GCAM_regID.csv"), check.names = FALSE)%>%
  tibble::as_tibble()
use_data(gcam_region_id, version=3, overwrite=T)

# gcam_region_name
gcam_region_name <- read.csv(paste0(saveDataFiles_folder,"/GCAM_region_names.csv"), check.names = FALSE)%>%
  tibble::as_tibble()
use_data(gcam_region_name, version=3, overwrite=T)

# IRENA_capacity
IRENA_capacity <- read.csv(paste0(saveDataFiles_folder,"/IRENA_capacity.csv"), check.names = FALSE)%>%
  tibble::as_tibble()
use_data(IRENA_capacity, version=3, overwrite=T)

# IRENA.mapping
IRENA.mapping <- read.csv(paste0(saveDataFiles_folder,"/IRENA.mapping.csv"), check.names = FALSE)%>%
  tibble::as_tibble()
use_data(IRENA.mapping, version=3, overwrite=T)

# IRENA.tech.mapping
IRENA.tech.mapping <- read.csv(paste0(saveDataFiles_folder,"/IRENA.tech.mapping.csv"), check.names = FALSE)%>%
  tibble::as_tibble()
use_data(IRENA.tech.mapping, version=3, overwrite=T)

# RE_ratio_2020
RE_ratio_2020 <- read.csv(paste0(saveDataFiles_folder,"/RE_Ratio_2020.csv"), check.names = FALSE)%>%
  tibble::as_tibble()
use_data(RE_ratio_2020, version=3, overwrite=T)

# elec_gen_map
elec_gen_map <- read.csv(paste0(saveDataFiles_folder,"/elec_gen_map_core.csv"), check.names = FALSE)%>%
  tibble::as_tibble()
use_data(elec_gen_map, version=3, overwrite=T)
