#First install packages below 
#Example: install.packages("terra", dependencies = TRUE)
#raster,analogues,stringr,grid,maptools,rgdal
#Some libraries like raster and gdal will not be supported beyond end of 2023. Most of the functionality will be covered in the future by the terra library, for now using older versions of R will permit running the script.
#Please note that the analogue library in the CRAN repository is not the analogues library utilized here, it needs to be installed from:
#install.packages("remotes")
#remotes::install_github("CIAT-DAPA/analogues")
# see details on https://github.com/CIAT-DAPA/analogues/

#load libraries

library(raster)
library(analogues)
library(stringr)
library(grid)
library(maptools)
library(rgdal)

#set the place where worldclim data will be downloaded
wd <-"C:/R_worldclim"
setwd(wd)
#download worldclim data for first time, after the initial download it will remain on the harddrive, permitting offline work. Resolution of climaten data is 2.5 min but can be increased or decreased depending
# on need and data available. If higher resolution data is available can also be utilized but will have to incorporporated manually. Same goes for the of parameters like eg soil Ph if similarity analysis 
# is not only supposed to be based on climate data

wc_prec <- raster::getData('worldclim', res=2.5,var='prec', path=wd)
wc_temp <- raster::getData('worldclim', res=2.5,var='tmean', path=wd)

#Load worldclim data after downloaded
# Source of Analogue rasters
raster_ini<-'C:/R_worldclim/wc2-5/'


# selecting rain files for raster processing

#rain_files<-sort(list.files(path =raster_ini,  pattern = "^prec.*\\.bil$", full.names = T))
rain_files<-paste0(raster_ini,"prec",seq(1:12),".bil")
rain_rasters<-lapply(rain_files, FUN = raster)

#selecting mean temperature  files  for raster processing
#tmean_files<-list.files(path =raster_ini,  pattern = "^tmean.*\\.bil$", full.names = T)
tmean_files<-paste0(raster_ini,"tmean",seq(1:12),".bil")
tmean_rasters<-lapply(tmean_files,FUN=raster)

#creating raster stacks for the analysis in analogue
wc_prec <- raster::stack(rain_rasters)
wc_temp <-raster::stack(tmean_rasters)

# Load site or list of sites, file input format is a csv text file with header = x,y,filename. Columns are separated by commas. First column x is longitude value in decimal degrees, second column is latitude value in decimal degrees
# third column is name or code of site can be alphanumeric and will be used as a filename for the final tiff raster file output. 

FileOfSites<-read.csv('C:/Projectfolder/ClimateSimilarity/sites.csv',header = TRUE,sep = ",", stringsAsFactors = FALSE )   

#Path for saving raster outputs
path_out<-'C:/Projectfolder/ClimateSimilarity/analogues'
#Run analogues, this permits running all coordinate pairs representing sites of interest
# This example uses precipitation and average temperature as climate parameters. Both parameters are weighted equal, if you want to change weights towards either one adjust values keeping total at 1.0
#growing.season refers to the time frame which to compare. Set to (1,12) it will do the aanlysis for the whole 12 monhts of the year, if you want to run only for a specific number of months adjust accordingly
# Rainy season from April to October growing.season=c(4,10)

for (i in 1:nrow(FileOfSites))
{
  
  Long<-FileOfSites[i,1]
  Lat<-FileOfSites[i,2]
  FileName<-FileOfSites[i,3]
  print(FileName)
  
  params <-  createParameters(x=Long, y=Lat, vars=c("prec","tmean"), weights=c(0.5,0.5), ndivisions=c(12,12),
                              growing.season=c(1,12),rotation="tmean",threshold=1,
                              env.data.ref=list(wc_prec,wc_temp), env.data.targ=list(wc_prec,wc_temp),
                              outfile=wd,fname=NA,writefile=FALSE)
  x <- calc_similarity(params)
  
  writeRaster(x, filename = paste0(path_out,FileName, ".tif"))
  gc()
  
}

#Output raster can be used for further analysis or mapping purposes in R or any GIS software
