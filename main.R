# Main

#install.packages("sp")
#install.packages("raster")
#install.packages("gstat")

library(shiny)
library(datasets)
library(leaflet)
library(rgdal)
library(raster)
library(sp)
library(gstat)
library(rPython)
library(maps)
source("R/functions.R")

# Run the python script which do all the pro-processing work. 
system("python Python/preprocessing.py")

# Run the R script which interpolate air pollution during the whole wildfire period
Interpolate_pollution() 
