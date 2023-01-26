library(sp)
library(tidyverse)
library(osmdata)
library(sf)
library(mapview)
############################################################Scrape POIs from OSM

bbox <- getbb("Nigeria", featuretype = "country")

osm <- opq(bbox = bbox, timeout = 360, memsize = 1000000000) %>%
  add_osm_feature(key = "amenity") %>%
  osmdata_sf()

table(osm$osm_points$amenity)
osm_points <- osm$osm_points

#get nigeria borders - pull in your own shapefile (this is fraym-specific command)
nga <- st_read("~/Dropbox (Fraym)/projects/johnson_johnson/phase_1/gis/nigeria/boundaries/nga_adm0.shp")

# Clip to country borders
osm <- osm_points[nga,]

osm_sf = osm %>%
  as.data.frame() %>%
  dplyr::select(osm_id, name, amenity, geometry) 


#Isolate POIs of interest

# https://wiki.openstreetmap.org/wiki/Map_features

osm_health_facilities <- c("clinic", "eha_hospital", "health_centre", "hospital_post", "pharmacy",
                      "Primary Health Centre")


osm_health_facilities_sf <- subset(osm_sf, osm_sf$amenity %in% osm_health_facilities)

osm_health_facilities_ll = osm_health_facilities_sf %>%
  mutate(geom = gsub(geometry,pattern="(\\))|(\\()|c",replacement = ""))%>%
  tidyr::separate(geom,into=c("lon","lat"),sep=",")%>%
  as.data.frame() %>%
  dplyr::select(-geometry) 

osm_health_facilities_ll$Latitude <- as.numeric(osm_health_facilities_ll$lat)
osm_health_facilities_ll$Longitude <- as.numeric(osm_health_facilities_ll$lon)
mapview(osm_health_facilities_ll, xcol = "Longitude", ycol = "Latitude", crs = 4269, grid = FALSE, zcol="amenity")
# export the osm data file
#write_csv(osm_food_markets_ll, "C:/Dropbox (Fraym)/projects/gates/Nutrition_LSFF/output/osm_gisgraphy/osm_food_markets.csv")

# Make into shapefile
#st_write(osm_health_facilities_sf, "C:/Dropbox (Fraym)/projects/gates/Nutrition_LSFF/output/osm_gisgraphy/all_food_markets.shp", delete_dsn = TRUE)

