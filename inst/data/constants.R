# This is the preparation script of the BRI Project
# define constants
# Ryna Cui, April 2020

CUMULATIVE_EMISSIONS_BUDGET_GOALS <- c(300, 400, 500, 600, 700, 800, 900, 950, 1000, 1200, 1400, 1600, 1800, 2000, 2500, 3000)

# Basic format conv_[from]_[to]
conv_thousand_million <- 1/1000
conv_million_billion <- 1/1000

# NOTE: These values are only used for queries that don't have an associated mapping file
# for queries such as primary_fuel_prices this conversion is specified in the mapping file
# These values are taken from GDP inflator in the GCAM R package
conv_90USD_10USD <- 1.515897
conv_75USD_10USD <- 3.227608
conv_15USD_10USD <- .91863
conv_19USD_75USD <- .2658798
conv_C_CO2 <- 44/12

# Elec related conversions
hr_per_yr <- 8760
EJ_to_GWh <- 0.0000036
EJ_to_TWh <- 277.778
MW_to_GW <- 1/1000
GW_to_MW <- 1000
GWh_to_MJ <- 3600000
KWh_to_GWh <- 1E-6


# GHG emission conversion
F_GASES <- c("C2F6", "CF4", "HFC125", "HFC134a", "HFC245fa", "SF6", "HFC143a", "HFC152a", "HFC227ea", "HFC23", "HFC236fa", "HFC32", "HFC365mfc")
GHG_gases <- c("CH4", "N2O", F_GASES, "CO2", "CO2LUC")

# Reporting years
GCAM_years <- c(1990, seq(2005, 2100, 5))
reporting_years <- seq(2005, 2100, 5)

long_columns <- c("scenario", "region", "var", "year", "value")

reporting_columns <- c("Model", "Scenario", "Region", "Variable", "Unit", reporting_years)

# -----------------------------------------------------------------------------
# define regions
# -----------------------------------------------------------------------------
bri_region <- c("China", "Indonesia", "Pakistan", "Central Asia", "Southeast Asia", "South Asia", "South Korea", "Taiwan",
                "EU-12", "Europe_Eastern", "Europe_Non_EU", "Russia", "Middle East", 
                "Africa_Northern", "Africa_Eastern", "Africa_Western", "Africa_Southern", "South Africa",
                "Central America and Carribean", "South America_Northern", "South America_Southern")

calculation_region <- c("Indonesia", "EU-12", "Middle East", "Africa_Northern", "South Asia",
                        "China", "Southeast Asia", "Central Asia", "Pakistan", "Russia", "South Africa",
                        "South Korea", "Central America and Caribbean", "Europe_Non_EU", "Europe_Eastern",
                        "Africa_Eastern", "Africa_Western", "Africa_Southern", "South America_Northern",
                        "South America_Southern")


