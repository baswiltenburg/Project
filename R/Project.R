#install.packages("rgeos")
#install.packages("rgdal")

library(raster)
library(rgeos)
library(rgdal)


setwd("/home/bram/Documenten/Project/R/")
boundaries1 <- readOGR("data/CA_counties.shp")

boundaries2 <- readOGR("data/tl_2012_04_cousub.shp")
boundaries2 <- spTransform(boundaries2, proj4string(boundaries1))

boundaries3 <- readOGR("data/Nevada_Counties_2015.shp")
boundaries3 <- spTransform(boundaries3, proj4string(boundaries1))

cities <- readOGR("data/tl_2013_06_place.shp")
cities <- spTransform(cities, proj4string(boundaries1))

project_extent <- extent(-123, -119.5, 34.9, 40)
plot(project_extent, col = "darkblue")

boundaries_1_crop <- crop(boundaries1, project_extent)
plot(boundaries_1_crop, add = TRUE, col = "darkgrey")
plot(spdf, add= TRUE, col="red")
#boundaries_2_crop <- crop(boundaries2, project_extent)
#plot(boundaries_2_crop, add = TRUE, col = "lightgrey")
#boundaries_3_crop <- crop(boundaries3, project_extent)
#plot(boundaries_3_crop, add = TRUE, col = "lightgrey")
#cities_crop <- crop(cities, project_extent)
#(cities_crop, add = TRUE, col = "black")
plot(spdf, add= TRUE, col="red")






