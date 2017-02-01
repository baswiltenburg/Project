Interpolate_pollution <- function(){
  # Convert data (.cvs) to SpatialPointDataFrame
  data <- read.csv("Python/output/preprocessing_results.csv")
  strtrim(data$Date,10)
  data$Date <- as.Date(as.character(data$Date), "%m/%d/%Y")
  firedates <- subset(data, Date > as.Date("2016-07-21") & Date < as.Date("2016-10-13"))
  coordinates <- cbind(firedates$SITE_LONGITUDE, firedates$SITE_LATITUDE)
  
  # Define project extent
  project_extent <- extent(-125, -114, 32, 43)
  #plot(project_extent, axes = TRUE)
  
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
  #lines(coords, col="red")
  sp_poly <- SpatialPolygons(list(Polygons(list(Polygon(coords)), ID=1)), proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  sp_poly_df <- SpatialPolygonsDataFrame(sp_poly, data=data.frame(ID=1))
  USA <- getData('GADM', country='USA', level=1)
  california <- USA[USA$NAME_1 == "California",]
  california <- spTransform(california, CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  df <- spdf_crop@data
  write.csv(df, file = "Dataframes/df_fire_period.csv") 
  
  system("python Python/create_dataframes.py")
  
  rasters <- stack()
  for(i in 0:81) {
    filename <- paste("Dataframes/day_",i,".csv",sep="")
    data_per_day <- read.csv(filename)
    coordinates_fd <- cbind(data_per_day$SITE_LONGITUDE, data_per_day$SITE_LATITUDE)
    fd_spdf <- SpatialPointsDataFrame(coords = coordinates_fd, data = data_per_day, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
    idw_cal <- idw(fd_spdf$Daily.Mean.PM2.5.Concentration ~ 1, fd_spdf, grd, idp=6)
    idw_cal_r <- raster(idw_cal)
    idw_cal_r_m <- mask(idw_cal_r, california, inverse = FALSE)
    rasters <- stack(rasters, idw_cal_r_m)
    #plot(idw_cal_r_m, axes=TRUE)
    #plot(sp_poly_df, add = TRUE)
    #plot(spdf_crop, pch=19, cex = 0.2, add = TRUE)
    #map("state", lwd=1, add =TRUE)
    #map("county", lwd=0.5, lty=3, add =TRUE)
    #mtext(data_per_day$Date[1], side =3, cex = 1, font = 2, line = 1)
  }
  return(rasters)
}
rasters <- Interpolate_pollution()


mapcolor <- colorBin(palette = c('green','yellow', 'red'), domain = c(0:35), bins = 50, pretty = FALSE, na.color = NA)
legendcolor <- colorBin(palette = c('green', 'yellow', 'red'), domain = c(0:35),  bins =8, pretty = FALSE, na.color = NA)
maxcolor <- colorBin(palette = c('red'), domain = c(35:110),  bins =2, pretty = FALSE, na.color = NA)

ui <- shinyUI(fluidPage(
  # Application title
  titlePanel("Air quality during a wildfire event"),
  sidebarLayout(
    # Sidebar with a slider input
    sidebarPanel(
      sliderInput("days", "Period of the 'Sherpa' wildfire", min = 1, max = 82, value = 1, step = 1, pre = 'Day ', animate = TRUE)),
    # Show a plot of the generated distribution
    mainPanel(
      leafletOutput("map")
    )
  )
))

server <- shinyServer(function(input, output){
  observe({
    output$map <- renderLeaflet(
      leaflet() %>% 
        addProviderTiles("Stamen.TonerLite") %>% 
        #addTiles() %>%
        setView(lng=-120, lat = 37, zoom = 6) %>%
        addLegend(position = "bottomright", pal = legendcolor, values = c(0:35), title = "Legend",labFormat = labelFormat(suffix = ' ug/m³'))
    )
    
  })
  observe({
    
    leafletProxy("map", data = rasters@layers[[input$days]]) %>%
    #clearGroup(group = "Pollution")%>%
    addRasterImage(rasters@layers[[input$days]], colors = mapcolor, opacity = 0.5, layerId = input$days, group = "Pollution")  %>%
    addRasterImage(rasters@layers[[input$days]], colors = maxcolor, opacity = 1)  %>%
    addLayersControl(baseGroups = c("Open Street Map"),overlayGroups = c("Pollution"), options = layersControlOptions(collapsed = FALSE)) 
  })
  
  observe({#Observer to show Popups on click
    click <- input$map_click
    if (!is.null(click)) {
      showpos(x=click$lng, y=click$lat)
    }
  })
  showpos <- function(x=NULL, y=NULL) {#Show popup on clicks
    #Translate Lat-Lon to cell number using the unprojected raster
    #This is because the projected raster is not in degrees, we cannot use it!
    depth <- projectRasterForLeaflet(rasters@layers[[input$days]])
    resol <- res(rasters@layers[[input$days]])
    cell <- cellFromXY(rasters@layers[[input$days]], c(x, y))
    
    if (!is.na(cell)) {#If the click is inside the raster...
      xy <- xyFromCell(rasters@layers[[input$days]], cell) #Get the center of the cell
      x <- xy[1]
      y <- xy[2]
      #Get row and column, to print later
      rc <- rowColFromCell(rasters@layers[[input$days]], cell)
      #Get value of the given cell
      val = depth[cell]
      content <- paste0("PM2.5 = ", round(val, 1), " ug/m³")
      proxy <- leafletProxy("map")
      #add Popup
      proxy %>% clearPopups() %>% addPopups(x, y, popup = content)
      #add rectangles for testing
      proxy %>% clearShapes() %>% addRectangles(x-resol[1]/2, y-resol[2]/2, x+resol[1]/2, y+resol[2]/2)
    }
  }
})

# Complete app with UI and server components
shinyApp(ui, server)





