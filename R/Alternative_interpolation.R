
#writeOGR(sp_poly_df, "chull", layer="chull", driver="ESRI Shapefile")

#TEST FASE MAANDAG VRAGEN
# http://rspatial.org/analysis/rst/4-interpolation.html

library(plotly)
library(rgdal)
library(rgeos)
library(deldir)
library(dismo)
library(ggplot2)

v <- voronoi(spdf_crop2)
ca <- aggregate(california)
vca <- intersect(v, ca) #Spatial Polygon Dataframe, how to plot?

vca_df <- vca@data # Create dataframe of the data 
vca_df$ID<-seq.int(nrow(vca_df)) # add unique Polygonnumber


c <- cbind(vca_df$SITE_LONGITUDE, vca_df$SITE_LATITUDE) # Matrix with coordinates
Pol <- Polygon(c, hole=as.logical(NA)) # Create Polygon

test <- SpatialPolygons(Pol, proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
# HOW TO CREATE A SPATIAL POLYGON AND A SPATIAL POLYGON DATAFRAME, HOW TO MAKE THE 'Srl'.

r <- raster(california, res=10000)
vr <- rasterize(vca_df, r, 'prec')
# How to Rasterize??
plot(vr)

p <- ggplot(vca@data, aes(x=SITE_LONGITUDE,y=SITE_LATITUDE)) + geom_polygon(aes(fill=Daily.Mean.PM2.5.Concentration[6]))
# Can't make it work..

# http://rspatial.org/analysis/rst/4-interpolation.html