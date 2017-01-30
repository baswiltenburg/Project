Interpolate_pollution <- function(){
  # Convert data (.cvs) to SpatialPointDataFrame
  data <- read.csv("Python/output/preprocessing_results.csv")
  strtrim(data$Date,10)
  data$Date <- as.Date(as.character(data$Date), "%m/%d/%Y")
  firedates <- subset(data, Date > as.Date("2016-07-21") & Date < as.Date("2016-10-13"))
  coordinates <- cbind(firedates$SITE_LONGITUDE, firedates$SITE_LATITUDE)
  
  # Define project extent
  project_extent <- extent(-123, -117.5, 34.9, 40)
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
  
  df <- spdf_crop@data
  write.csv(df, file = "Dataframes/df_fire_period.csv") 
  
  system("python Python/create_dataframes.py")
  
  # USA <- getData('GADM', country='USA', level=1)
  # california <- USA[USA$NAME_1 == "California",]
  # california <- spTransform(california, CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  
  for(i in 0:81) {
    filename <- paste("Dataframes/day_",i,".csv",sep="")
    data_per_day <- read.csv(filename)
    coordinates_fd <- cbind(data_per_day$SITE_LONGITUDE, data_per_day$SITE_LATITUDE)
    fd_spdf <- SpatialPointsDataFrame(coords = coordinates_fd, data = data_per_day, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
    idw_cal <- idw(fd_spdf$Daily.Mean.PM2.5.Concentration ~ 1, fd_spdf, grd, idp=6)
    idw_cal_r <- raster(idw_cal)
    idw_cal_r_m <- mask(idw_cal_r, sp_poly_df, inverse = FALSE)
    plot(idw_cal_r_m, axes=TRUE)
    plot(sp_poly_df, add = TRUE)
    plot(spdf_crop, pch=19, cex = 0.2, add = TRUE)
    map("state", lwd=1, add =TRUE)
    map("county", lwd=0.5, lty=3, add =TRUE)
    mtext(data_per_day$Date[1], side =3, cex = 1, font = 2, line = 1)
  }
  return(idw_cal_r_m)
}

idw_cal_r_m <- Interpolate_pollution()


### Plot in Shiny webinterface using leaflet
library(shiny)

#Prepare UI
ui <- pageWithSidebar(
  # Application title
  headerPanel("Air quality during a wildfire event"),
  # Sidebar with sliders whos sum should be constrained to be 100
  sidebarPanel(
    sliderInput("slider1", label = h3("Slider"), min = 0, max = 1, value = 0, step=1),
    # Create table output
    mainPanel(map)
  ))

server <- function(input, output, session) {
  output$value <- renderPrint({ input$slider1 })
  
  map = leaflet() %>% addTiles() %>%
    #addProviderTiles("Stamen.TerrainBackground") %>% 
    addRasterImage(idw_stack@layers[input$slider1], colors = colorRampPalette(c("yellow", "red"))(length(seq(0, 100, by = 1))-1), opacity = 0.6)
  
  output$map = renderLeaflet(map)
  textOutput
  
    observe({#Observer to show Popups on click
    click <- input$map_click
    if (!is.null(click)) {
      showpos(x=click$lng, y=click$lat)
    }
  })
  
  showpos <- function(x=NULL, y=NULL) {#Show popup on clicks
    #Translate Lat-Lon to cell number using the unprojected raster
    #This is because the projected raster is not in degrees, we cannot use it!
    cell <- cellFromXY(idw_cal_r_m, c(x, y))
    if (!is.na(cell)) {#If the click is inside the raster...
      xy <- xyFromCell(idw_cal_r_m, cell) #Get the center of the cell
      x <- xy[1]
      y <- xy[2]
      #Get row and column, to print later
      rc <- rowColFromCell(idw_cal_r_m, cell)
      #Get value of the given cell
      val = depth[cell]
      content <- paste0("PM2.5 = ", round(val, 1), " ppm")
      proxy <- leafletProxy("map")
      #add Popup
      proxy %>% clearPopups() %>% addPopups(x, y, popup = content)
      #add rectangles for testing
      proxy %>% clearShapes() %>% addRectangles(x-resol[1]/2, y-resol[2]/2, x+resol[1]/2, y+resol[2]/2)
    }
  }
}

shinyApp(ui = ui, server = server)

leaflet() %>% addTiles() %>%
  #addProviderTiles("Stamen.TerrainBackground") %>% 
  addRasterImage(idw_cal_r_m, colors = colorRampPalette(c("yellow", "red"))(length(seq(0, 100, by = 1))-1), opacity = 0.6)

######################################################################################

# http://rstudio.github.io/shiny/tutorial/#ui-and-server

# Define UI for dataset viewer application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Reactivity"),
  
  # Sidebar with controls to provide a caption, select a dataset, and 
  # specify the number of observations to view. Note that changes made
  # to the caption in the textInput control are updated in the output
  # area immediately as you type
  sidebarPanel(
    textInput("caption", "Caption:", "Data Summary"),
    
    selectInput("dataset", "Choose a dataset:", 
                choices = c("rock", "pressure", "cars")),
    
    numericInput("obs", "Number of observations to view:", 10)
  ),
  
  
  # Show the caption, a summary of the dataset and an HTML table with
  # the requested number of observations
  mainPanel(
    h3(textOutput("caption")), 
    
    verbatimTextOutput("summary"), 
    
    tableOutput("view")
  )
))

library(shiny)
library(datasets)

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output) {
  
  # By declaring datasetInput as a reactive expression we ensure that:
  #
  #  1) It is only called when the inputs it depends on changes
  #  2) The computation and result are shared by all the callers (it 
  #     only executes a single time)
  #
  datasetInput <- reactive({
    switch(input$dataset,
           "rock" = rock,
           "pressure" = pressure,
           "cars" = cars)
  })
  
  # The output$caption is computed based on a reactive expression that
  # returns input$caption. When the user changes the "caption" field:
  #
  #  1) This expression is automatically called to recompute the output 
  #  2) The new caption is pushed back to the browser for re-display
  # 
  # Note that because the data-oriented reactive expressions below don't 
  # depend on input$caption, those expressions are NOT called when 
  # input$caption changes.
  output$caption <- renderText({
    input$caption
  })
  
  # The output$summary depends on the datasetInput reactive expression, 
  # so will be re-executed whenever datasetInput is invalidated
  # (i.e. whenever the input$dataset changes)
  output$summary <- renderPrint({
    dataset <- datasetInput()
    summary(dataset)
  })
  
  # The output$view depends on both the databaseInput reactive expression
  # and input$obs, so will be re-executed whenever input$dataset or 
  # input$obs is changed. 
  output$view <- renderTable({
    head(datasetInput(), n = input$obs)
  })
})




