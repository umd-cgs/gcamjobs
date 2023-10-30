#' capacity
#'
#' Function that calculates capacity
#'
#' @param fig_dir Default = NULL, Output folder for figures and maps.
#' @param prj_data Default = NULL, Gcam output data in "dat" format.
#' @param input_dir Default = getwd(),output direction
#' @param scenarios Default = NULL
#' @param ref_scenario Default = NULL
#' @keywords sum
#' @return number
#' @import dplyr
#' @import tidyr
#' @import rgcam
#' @import rlang
#' @export
#' @examples
#' \dontrun{
#' library(gcamjobs)
#' gcamjobs::capacity (1,1)
#' }
#'


capacity <- function(fig_dir = NULL,
                     prj_data = NULL,
                     input_dir = getwd(),
                     scenarios  = NULL,
                     ref_scenario  = NULL) {
  #.........................
  # Initialize
  #.........................

  rlang::inform("Starting capacity...")


  # Load the constants
  const_file <- system.file("data", "constants.R", package = "gcamjobs")
  if (length(const_file) == 0) {
    stop("constants.R not found in package data")
  }
  source(const_file, chdir = TRUE)

  #.........................
  # Run Function
  #.........................

  output = NULL

  rlang::inform("reading prj...")
  prj <- rgcam::loadProject(paste0(input_dir, "/", prj_data))
  all_scenarios <- rgcam::listScenarios (prj)
  queries = rgcam::listQueries(prj)

  #.........................
  # Test scenarios
  #.........................
  if(!all(scenarios %in% all_scenarios)){
    rlang::warn("Not all the scenarios selected are in the database selected.")
  }

  #.........................
  # Initial data
  #.........................

  # # process IRENA data
  gcamjobs::IRENA_capacity %>%
    select(Country, ISO.Code, Group.Technology, Technology, Producer.Type, Year, Electricity.Installed.Capacity..MW.) %>%
    rename(MW = "Electricity.Installed.Capacity..MW.") %>%
    filter(Group.Technology %in% c("Solar energy", "Wind energy"), Year == 2020) %>%
    mutate(ISO.Code = tolower(ISO.Code),
           ISO.Code = gsub("rou", "rom", ISO.Code),
           ISO.Code = gsub("xkx", "scg", ISO.Code),
           ISO.Code = gsub("bes", "ant", ISO.Code),
           value = MW,
           value =as.numeric(gsub(",", "", value))) %>%
    rename(year = Year) %>%
    left_join(gcam_region_id, by = c("ISO.Code" = "iso")) %>%
    left_join(gcam_region_name, by = "GCAM_region_ID") %>%
    filter(!is.na(region)) -> IRENA_capacity_clean
  #
#
  IRENA_capacity_clean %>%
    left_join(IRENA.mapping %>%
                select(-technology))%>%
    group_by(region, year, var) %>%
    summarise(value = sum(value, na.rm = T) * MW_to_GW) %>%
    ungroup() %>%
    mutate(scenario = ref_scenario) %>%
    tidyr::complete(tidyr::nesting(region, year, var, value),
             scenario = unique(scenarios),
             fill = list(value =0)) %>%
    select(scenario, year, value, region, var) -> IRENA_capacity_var

#   #
#   IRENA_capacity_clean %>%
#     left_join(IRENA.tech.mapping) %>%
#     filter(!technology %in% c("rooftop_pv", "wind_offshore")) %>%
#     select(region, technology, year, value) %>%
#     # scale RE values to RE:RE storage ratio
#     left_join(RE_ratio_2020) %>%
#     mutate(tech_storage = ifelse(technology=="PV", value * PV_ratio, NA),
#            tech_storage = ifelse(technology=="CSP", value * CSP_ratio, tech_storage),
#            tech_storage = ifelse(technology=="wind", value * Wind_ratio, tech_storage),
#            technology = paste0(technology, "_storage"),
#            value = tech_storage) %>%
#     select(-CSP_ratio, -PV_ratio, -Wind_ratio, -tech_storage) %>%
#
#     # add original IRENA data
#     bind_rows(IRENA_capacity_clean %>%
#                 left_join(IRENA.tech.mapping) %>%
#                 select(region, technology, year, value)) %>%
#     group_by(region, year, technology) %>%
#     summarise(value = sum(value, na.rm = T) * MW_to_GW) %>%
#     ungroup() %>%
#     mutate(scenario = ref_scenario) %>%
#     complete(nesting(region, year, technology, value),
#              scenario = unique(scenarios),
#              fill = list(value =0)) -> IRENA_capacity_tech



  #.........................
  # Saving outputs
  #.........................
  output = list(all_scenarios = all_scenarios,
                queries = queries)


  #.........................
  # Close out
  #.........................


  rlang::inform("capacity complete.")

  return(output)

}

