library(gcamjobs)
library(rgcam)
#testing funcation capacity
input_dir_i = "/Users/Zt/Desktop/CGS_BRI/output/"
prj_data_i = "GCAM_1.5_12_12.dat"
gcamjobs::capacity(prj_data = prj_data_i,
                   input_dir = input_dir_i)->
  my_outputs

my_outputs$scenarios
my_outputs$queries
