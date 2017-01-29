
# Convert data (.cvs) to SpatialPointDataFrame
test_cvs <- read.csv("Python/output/preprocessing_results.csv")

substract <- test_cvs[test_cvs$Date == "01/11/2003",]

coordinates <- cbind(substract$SITE_LONGITUDE, substract$SITE_LATITUDE)

spdf <- SpatialPointsDataFrame(coords = coordinates, data = substract,
                               proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))

# Plot air-quality stations across California
USA <- getData('GADM', country='USA', level=1)
california <- USA[USA$NAME_1 == "California",]

plot(california)
plot(spdf, add= TRUE, col="red")

# Define project extent
project_extent <- extent(-123, -117, 34.9, 40)
plot(project_extent, add=TRUE)

# Create empty raster
raster <- raster(project_extent, nrows=500, ncols=500)
grd.pts <- SpatialPixels(SpatialPoints((raster)))
grd <- as(grd.pts, "SpatialGrid")
proj4string(grd) <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")

# IDW calculation
idw_cal <- idw(spdf$Daily.Max.8.hour.CO.Concentration ~ 1, spdf, grd, idp=6)
plot(idw_cal)


## spplot test
spplot(idw_cal["var1.pred"])
image(idw_cal, xlim=c(-123, -117), ylim=c(34, 41.2))
map("state", lwd=1, add=T)
map("county", lty=3, lwd=0.5, add=T)
#points(spdf, pch=21, bg="blue")

