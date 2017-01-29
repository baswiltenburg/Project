library(rgdal)
library(raster)
library(sp)
library(gstat)
library(rPython)

Interpolate_pollution <- function(){
  
  # Convert data (.cvs) to SpatialPointDataFrame
  data <- read.csv("Python/output/preprocessing_results.csv")
  strtrim(data$Date,10)
  data$Date <- as.Date(as.character(data$Date), "%m/%d/%Y")
  firedates <- subset(data, Date > as.Date("2016-07-21") & Date < as.Date("2016-10-13"))
  coordinates <- cbind(firedates$SITE_LONGITUDE, firedates$SITE_LATITUDE)
  
  # Define project extent
  project_extent <- extent(-123, -117.5, 34.9, 40)
  plot(project_extent, axes = TRUE)
  
  #Create empty raster
  raster <- raster(project_extent, nrows=50, ncols= 50)
  grd.pts <- SpatialPixels(SpatialPoints((raster)))
  grd <- as(grd.pts, "SpatialGrid")
  proj4string(grd) <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  
  # Create closed polygon around all points within extend
  coordinates <- cbind(firedates$SITE_LONGITUDE, firedates$SITE_LATITUDE)
  spdf <- SpatialPointsDataFrame(coords = coordinates, data = firedates, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  spdf_crop <- crop(spdf, project_extent)
  coordinates_crop <- cbind(spdf_crop$SITE_LONGITUDE, spdf_crop$SITE_LATITUDE)
  set.seed(1)
  ch <- chull(coordinates_crop)
  coords <- coordinates_crop[c(ch, ch[1]), ]  # closed polygon
  lines(coords, col="red")
  sp_poly <- SpatialPolygons(list(Polygons(list(Polygon(coords)), ID=1)), proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  sp_poly_df <- SpatialPolygonsDataFrame(sp_poly, data=data.frame(ID=1))
  
  USA <- getData('GADM', country='USA', level=1)
  california <- USA[USA$NAME_1 == "California",]
  california <- spTransform(california, CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  
  # NOG NIET GOED!
  for(i in 1:nrow(spdf_crop@data)) {
    row <- spdf_crop@data[i,]
    # IDW calculation
    idw_cal <- idw(row$Daily.Mean.PM2.5.Concentration ~ 1, row, grd, idp=6)
    idw_cal_r <- raster(idw_cal)
    idw_cal_r_m <- mask(idw_cal_r, sp_poly_df, inverse = FALSE)
    
    plot(california)
    plot(idw_cal_r_m, add=TRUE)
    plot(sp_poly_df, add = TRUE)
    plot(spdf_crop, pch=19, cex = 0.2, add = TRUE)
  }
} 


# DO SOMETHING LIKE THIS: (make for each date a spatial point dateframe and loop trough it)

df <- spdf_crop@data
firstdate <- subset(df, Date == as.Date("2016-07-22"))
coordinates_fd <- cbind(firstdate$SITE_LONGITUDE, firstdate$SITE_LATITUDE)
fd_spdf <- SpatialPointsDataFrame(coords = coordinates_fd, data = firstdate, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
idw_cal <- idw(fd_spdf$Daily.Mean.PM2.5.Concentration ~ 1, fd_spdf, grd, idp=6)
idw_cal_r <- raster(idw_cal)
idw_cal_r_m <- mask(idw_cal_r, sp_poly_df, inverse = FALSE)
plot(california, axes = TRUE)
plot(idw_cal_r_m, add=TRUE)
plot(sp_poly_df, add = TRUE)
plot(spdf_crop, pch=19, cex = 0.2, add = TRUE)
mtext(firstdate$Date[1], side =3, cex = 1, font = 2, line = 1)

df <- spdf_crop@data
firstdate <- subset(df, Date == as.Date("2016-07-23"))
coordinates_fd <- cbind(firstdate$SITE_LONGITUDE, firstdate$SITE_LATITUDE)
fd_spdf <- SpatialPointsDataFrame(coords = coordinates_fd, data = firstdate, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
idw_cal <- idw(fd_spdf$Daily.Mean.PM2.5.Concentration ~ 1, fd_spdf, grd, idp=6)
idw_cal_r <- raster(idw_cal)
idw_cal_r_m <- mask(idw_cal_r, sp_poly_df, inverse = FALSE)
plot(california)
plot(idw_cal_r_m, add=TRUE)
plot(sp_poly_df, add = TRUE)
plot(spdf_crop, pch=19, cex = 0.2, add = TRUE)
mtext(firstdate$Date[1], side =3, cex = 1, font = 2, line = 1)

df <- spdf_crop@data
firstdate <- subset(df, Date == as.Date("2016-07-24"))
coordinates_fd <- cbind(firstdate$SITE_LONGITUDE, firstdate$SITE_LATITUDE)
fd_spdf <- SpatialPointsDataFrame(coords = coordinates_fd, data = firstdate, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
idw_cal <- idw(fd_spdf$Daily.Mean.PM2.5.Concentration ~ 1, fd_spdf, grd, idp=6)
idw_cal_r <- raster(idw_cal)
idw_cal_r_m <- mask(idw_cal_r, sp_poly_df, inverse = FALSE)
plot(california)
plot(idw_cal_r_m, add=TRUE)
plot(sp_poly_df, add = TRUE)
plot(spdf_crop, pch=19, cex = 0.2, add = TRUE)
mtext(firstdate$Date[1], side =3, cex = 1, font = 2, line = 1)

df <- spdf_crop@data
firstdate <- subset(df, Date == as.Date("2016-07-25"))
coordinates_fd <- cbind(firstdate$SITE_LONGITUDE, firstdate$SITE_LATITUDE)
fd_spdf <- SpatialPointsDataFrame(coords = coordinates_fd, data = firstdate, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
idw_cal <- idw(fd_spdf$Daily.Mean.PM2.5.Concentration ~ 1, fd_spdf, grd, idp=6)
idw_cal_r <- raster(idw_cal)
idw_cal_r_m <- mask(idw_cal_r, sp_poly_df, inverse = FALSE)
plot(california)
plot(idw_cal_r_m, add=TRUE)
plot(sp_poly_df, add = TRUE)
plot(spdf_crop, pch=19, cex = 0.2, add = TRUE)
mtext(firstdate$Date[1], side =3, cex = 1, font = 2, line = 1)

df <- spdf_crop@data
firstdate <- subset(df, Date == as.Date("2016-07-26"))
coordinates_fd <- cbind(firstdate$SITE_LONGITUDE, firstdate$SITE_LATITUDE)
fd_spdf <- SpatialPointsDataFrame(coords = coordinates_fd, data = firstdate, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
idw_cal <- idw(fd_spdf$Daily.Mean.PM2.5.Concentration ~ 1, fd_spdf, grd, idp=6)
idw_cal_r <- raster(idw_cal)
idw_cal_r_m <- mask(idw_cal_r, sp_poly_df, inverse = FALSE)
plot(california)
plot(idw_cal_r_m, add=TRUE)
plot(sp_poly_df, add = TRUE)
plot(spdf_crop, pch=19, cex = 0.2, add = TRUE)
mtext(firstdate$Date[1], side =3, cex = 1, font = 2, line = 1)

df <- spdf_crop@data
firstdate <- subset(df, Date == as.Date("2016-07-27"))
coordinates_fd <- cbind(firstdate$SITE_LONGITUDE, firstdate$SITE_LATITUDE)
fd_spdf <- SpatialPointsDataFrame(coords = coordinates_fd, data = firstdate, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
idw_cal <- idw(fd_spdf$Daily.Mean.PM2.5.Concentration ~ 1, fd_spdf, grd, idp=6)
idw_cal_r <- raster(idw_cal)
idw_cal_r_m <- mask(idw_cal_r, sp_poly_df, inverse = FALSE)
plot(california)
plot(idw_cal_r_m, add=TRUE)
plot(sp_poly_df, add = TRUE)
plot(spdf_crop, pch=19, cex = 0.2, add = TRUE)
mtext(firstdate$Date[1], side =3, cex = 1, font = 2, line = 1)




