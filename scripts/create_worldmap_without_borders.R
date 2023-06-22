library(rgdal) #for the CRS function
library(magrittr) #for the %$% operator
library(raster)
library(here)

##we'll prepare a world map for our plots
#Using the original maps package, then converting map into SpatialPolygons object
world <- maps::map("world", fill=TRUE) %$%
  maptools::map2SpatialPolygons(., IDs=names,proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs"))
#The resulting map has self intersection problems so any further operation reports errors; using buffers of width 0 is a fast fix
while(rgeos::gIsValid(world)==FALSE){
  world <- rgeos::gBuffer(world, byid = TRUE, width = 0, quadsegs = 5, capStyle = "ROUND")
}
#Dissolving polygon's limits
world <- raster::aggregate(world)

saveRDS(world,paste0(here::here(),"/miscellaneous/worldmap_continents.rds"))
