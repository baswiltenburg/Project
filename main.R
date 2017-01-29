# Main

#install.packages("sp")
#install.packages("raster")
#install.packages("gstat")

library(raster)
library(sp)
library(gstat)
source("R/functions2.R")

# Run the python script which do all the pro-processing work. 
system("python Python/main.py")
dataframe <- Create_Spatial_Point_Dataframe()
