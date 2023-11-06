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
  #
  IRENA_capacity_clean %>%
    left_join(IRENA.tech.mapping) %>%
    filter(!technology %in% c("rooftop_pv", "wind_offshore")) %>%
    select(region, technology, year, value) %>%
# scale RE values to RE:RE storage ratio
left_join(RE_ratio_2020) %>%
mutate(tech_storage = ifelse(technology=="PV", value * PV_ratio, NA),
       tech_storage = ifelse(technology=="CSP", value * CSP_ratio, tech_storage),
       tech_storage = ifelse(technology=="wind", value * Wind_ratio, tech_storage),
       technology = paste0(technology, "_storage"),
       value = tech_storage) %>%
select(-CSP_ratio, -PV_ratio, -Wind_ratio, -tech_storage) %>%

    # add original IRENA data
    bind_rows(IRENA_capacity_clean %>%
                left_join(IRENA.tech.mapping) %>%
                select(region, technology, year, value)) %>%
    group_by(region, year, technology) %>%
    summarise(value = sum(value, na.rm = T) * MW_to_GW) %>%
    ungroup() %>%
    mutate(scenario = ref_scenario) %>%
    complete(nesting(region, year, technology, value),
             scenario = unique(scenarios),
             fill = list(value =0)) -> IRENA_capacity_tech

  # ==============================================================================================
  # Capacity and investment
  # ==============================================================================================
  # Calculate electricity generation
  getQuery(prj, "elec gen by gen tech") %>%
    left_join(elec_gen_map, by = c("output", "subsector", "technology")) %>%
    filter(!is.na(var)) %>%
    mutate(value = value * unit_conv) %>%
    group_by(scenario, region, year, var) %>%
    summarise(value = sum(value, na.rm = T)) %>%
    ungroup() %>%
    select(long_columns) ->
    elec_gen_tech_clean

  # getQuery(prj, "elec gen by gen tech") %>%
  #  group_by(scenario, year, subsector, technology) %>%
  #  summarise(value = sum(value, na.rm = T)) %>%
  #  mutate(region = "BRI") %>%
  #  ungroup()  %>%
  #  write.csv("/Users/mac/Desktop/elecgen.csv") (this part is comment)

  # # calculate regional coal capacity separately using GCPT data.
  GCPT_capacity %>%
    mutate(technology = "coal (conv pul)",
           year = 2020,
           #convert MW to GW
           value_coal = Operating * MW_to_GW) %>%
    select(-Operating) -> GCPT_capacity_clean
  #
  # # calculate cf for coal
  getQuery(prj, "elec gen by gen tech") %>%
    filter(year == 2020,
           technology == "coal (conv pul)",
           scenario == ref_scenario) %>%
    rename(EJ = value) %>%
    left_join(GCPT_capacity_clean) %>%
    rename(value = value_coal) %>%
    mutate(cf_coal = EJ / (value * hr_per_yr * EJ_to_GWh),
           cf_coal = replace(cf_coal, cf_coal > 1, 0.99)) %>%
    rename(vintage = year) %>%
    select(technology, cf_coal, region, vintage) %>%
    complete(nesting(technology, cf_coal, region),
             vintage = seq(2005, 2100, by = 5)) -> coal_cf
  #
  #
  # ## first check global existing capacity from IEA, calculate cf for existing capacity
  elec_gen_tech_clean %>%
    filter(year == 2020, scenario == ref_scenario) %>%
    group_by(var) %>%
    summarise(EJ = sum(value, na.rm = T)) %>%
    ungroup %>%
    left_join(iea_capacity %>%
                filter(period == 2020, scenario == "Current Policies Scenario") %>%
                mutate(variable = gsub("Capacity", "Secondary Energy", variable)),
              by = c("var" = "variable")) %>%
    mutate(cf = EJ / (value * hr_per_yr * EJ_to_GWh),
           cf = replace(cf, cf > 1, 0.99)) %>%
    filter(!is.na(cf), !var %in% c("Secondary Energy|Electricity", "Secondary Energy|Electricity|Non-Biomass Renewables")) %>%
    left_join(elec_gen_map, by = "var") %>%
    select(technology, cf) %>%
    mutate(region = "USA", vintage = 2020) %>%
    complete(nesting(technology, cf),
             vintage = c(1990, seq(2005, 2020, by = 5)),
             region = unique(cf_rgn$region)) %>%
    filter(technology != "coal (conv pul)")-> cf_iea
  #
  # # use GCAM cf for future capacity
  cf_gcam %>%
    select(technology, cf = X2100) %>%
    mutate(region = "USA", vintage = 2025) %>%
    complete(nesting(technology, cf),
             vintage = seq(2025, 2100, by = 5),
             region = unique(cf_rgn$region)) %>%
    # join with coal cf from GCPT
    bind_rows(coal_cf %>%
                filter(vintage < 2025,
                       !is.na(cf_coal))) %>%
    mutate(cf = ifelse(!is.na(cf_coal), cf_coal, cf)) %>%
    # replace regional cf for wind and solar
    left_join(cf_rgn  %>%
                # join with China solar cf
                left_join(China_solar) %>%
                mutate(capacity.factor = replace(capacity.factor, !is.na(capacity.factor.new), capacity.factor.new[!is.na(capacity.factor.new)])) %>%
                select(region, technology = stub.technology, vintage = year, cf.rgn = capacity.factor),
              by = c("technology", "vintage", "region")) %>%
    mutate(cf = replace(cf, !is.na(cf.rgn), cf.rgn[!is.na(cf.rgn)])) %>%
    # second, use iea capacity consistent cf for existing vintage
    bind_rows(cf_iea) %>%
    complete(nesting(technology, region), vintage = c(1990, seq(2005, 2100, by = 5))) %>%
    group_by(technology, region) %>%
    mutate(cf = approx_fun(vintage, cf, rule = 2)) -> elec_cf


  # ----------------------------------------------------------------------------------
  # Total Capacity
  # ----------------------------------------------------------------------------------
  getQuery(prj, "elec gen by gen tech and cooling tech and vintage") %>%
    filter(!sector %in% c("electricity", "elect_td_bld")) %>%
    separate(technology, into = c("technology", "vintage"), sep = ",") %>%
    mutate(vintage = as.integer(sub("year=", "", vintage))) %>%
    group_by(scenario, region, technology = subsector, vintage, year) %>%
    summarise(value = sum(value, na.rm = T)) %>%
    ungroup %>%
    bind_rows(getQuery(prj, "elec gen by gen tech and cooling tech and vintage") %>%
                filter(sector %in% c("electricity", "elect_td_bld")) %>%
                separate(technology, into = c("technology", "vintage"), sep = ",") %>%
                mutate(vintage = as.integer(sub("year=", "", vintage))) %>%
                group_by(scenario, region, technology, vintage, year) %>%
                summarise(value = sum(value, na.rm = T)) %>%
                ungroup) %>%
    filter(scenario %in% BRI_scenarios) %>%
    #filter out solar and wind values in 2020
    filter(year != 2020 |
             !technology %in% c("PV", "PV_storage",
                                "CSP", "CSP_storage", "wind", "rooftop_pv",
                                "wind_offshore", "wind_storage")) %>%
    group_by(scenario, region, technology, vintage, year) %>%
    summarise(value = sum(value, na.rm = T)) %>%
    ungroup %>%
    left_join(elec_cf, by = c("region", "technology", "vintage")) %>%
    mutate(EJ = value) %>%
    conv_EJ_GW() %>%
    group_by(scenario, region, technology, year) %>%
    summarise(value = sum(gw, na.rm = T)) %>%
    ungroup %>%
    # replace solar and wind values with IRENA values for 2020
    bind_rows(IRENA_capacity_tech %>%
                filter(scenario %in% BRI_scenarios)) %>%
    group_by(scenario, region, technology, year) %>%
    summarise(value = sum(value, na.rm = T)) %>%
    ungroup %>%
    filter(!grepl("cogen", technology)) %>%
    complete(nesting(scenario, region, year),
             technology = unique(technology),
             fill = list(value =0)) %>%
    mutate(var = paste0("Capacity|", technology),
           units = "GW") %>%
    select(long_columns, technology, units)->
    elec_capacity_tot_clean


  # Electricity total capacity by vintage
  # note: no IRENA data by vintage... so didn't substitute here
  getQuery(prj, "elec gen by gen tech and cooling tech and vintage") %>%
    filter(!sector %in% c("electricity", "elect_td_bld")) %>%
    separate(technology, into = c("technology", "vintage"), sep = ",") %>%
    mutate(vintage = as.integer(sub("year=", "", vintage))) %>%
    group_by(scenario, region, technology = subsector, vintage, year) %>%
    summarise(value = sum(value, na.rm = T)) %>%
    ungroup %>%
    bind_rows(getQuery(prj, "elec gen by gen tech and cooling tech and vintage") %>%
                filter(sector %in% c("electricity", "elect_td_bld")) %>%
                separate(technology, into = c("technology", "vintage"), sep = ",") %>%
                mutate(vintage = as.integer(sub("year=", "", vintage))) %>%
                group_by(scenario, region, technology, vintage, year) %>%
                summarise(value = sum(value, na.rm = T)) %>%
                ungroup) %>%
    filter(scenario %in% BRI_scenarios) %>%
    left_join(elec_cf, by = c("region", "technology", "vintage")) %>%
    mutate(EJ = value) %>%
    conv_EJ_GW() %>%
    group_by(scenario, region, technology, vintage, year) %>%
    summarise(value = sum(gw, na.rm = T)) %>%
    ungroup %>%
    filter(!grepl("cogen", technology)) %>%
    mutate(var = paste0("Capacity|", technology)) %>%
    select(long_columns, technology, vintage) -> elec_capacity_tot_vintage

  # # GGPLOT
  # elec_capacity_tot_clean %>%
  #   filter( scenario %in% BRI_scenarios) %>%
  #   filter(year %in% reporting_years, year <2055) %>%
  #   ggplot() +
  #   geom_bar(aes(x = year, y = value, fill = technology), stat = "identity", size = 1) +
  #   theme_bw() +
  #   theme(axis.text.x = element_text(angle=90)) +
  #   scale_x_continuous(breaks = seq(2010, 2100, by = 10), expand = c(0, 0)) +
  #   ggtitle("Electricity Capacity") +
  #   facet_wrap(~scenario) +
  #   ylab("Total capacity (GW)") +
  #   ggsave(paste0(fig_dir, "/elec_capacity_July23_tech.png"), width = 8, height = 5)

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

