library(gcamjobs)
library(rgcam)
library(dplyr)
#testing funcation capacity
input_dir_i = "//Users/Zt/Desktop/CGS_BRI/Repo/output/"
prj_data_i = "GCAM_1.5_12_12.dat"
scenarios_i <- c("BRI_1.5c_223230_gcam54_pricelink", "BRI_1.5c_2050_fullbio_pricelink","BRI_1.5c_2050_noLUC_fullbio_pricelink2","BRI_1.5c_2050_fullLUC_limbio_pricelink","BRI_1.5c_2050_fullLUC_fullbio_pricelink",
                 "BRI_1.5c_2050_CO2BLDTRN_pricelink","BRI_1.5c_2050_AllRegions_pricelink","BRI_1.5c_2050_ctax_exp_sct","BRI_gcam54_cpol_updelec")

ref_scenario_i <- "BRI_gcam54_cpol_updelec"

gcamjobs::capacity(prj_data = prj_data_i,
                   input_dir = input_dir_i,
                   scenarios  = scenarios_i,
                   ref_scenario  = ref_scenario_i)->
  my_outputs

my_outputs$scenarios
my_outputs$queries
