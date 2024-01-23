#First install packages below 
#Example: install.packages("terra", dependencies = TRUE)
#raster,analogues,stringr,grid,maptools,rgdal
#Some libraries like raster and gdal will not be supported beyond end of 2023. Most of the functionality will be covered in the future by the terra library, for now using older versions of R will permit running the script.
#Please note that the analogue library in the CRAN repository is not the analogues library utilized here, it needs to be installed from:
#install.packages("remotes")
#remotes::install_github("CIAT-DAPA/analogues")
# see details on https://github.com/CIAT-DAPA/analogues/

library(terra)
library(raster)
library(analogues)
library(stringr)
library(grid)
library(maptools)
library(rgdal)
library(sp)


# download climate data for the first  time, from worldclim
#  for that,create a folder like "R_worldclim" and use it as a path for download worldclim data

WorldClima_path <-"C:/R_worldclim"
wc_prec <- raster::getData('worldclim', res=2.5,var='prec', path=WorldClima_path)
wc_temp <- raster::getData('worldclim', res=2.5,var='tmean', path=WorldClima_path)

#download worldclim data for first time, after the initial download it will remain on the harddrive, permitting offline work. Resolution of climaten data is 2.5 min but can be increased or decreased depending
# on need and data available. If higher resolution data is available can also be utilized but will have to incorporporated manually. Same goes for the of parameters like eg soil Ph if similarity analysis 
# is not only supposed to be based on climate data

# IF you dont want or need global level you can cut the climate inpout rasters according to the region of interest

# Shape file used for Mask
pathMask<-'C:/R_worldclim/prueba/Mask/MexLimits.shp'
# Place where raster cut will be saved
pathRasterClipped<-'C:/R_worldclim/prueba/clipped/'
# Source of Analogue rasters
raster_ini<-'C:/R_worldclim/wc2-5/'
# Final rasters
raster_out<-'C:/R_worldclim/prueba/out/'


#Reading Shape file for cutting world rasters
MaskFile<-shapefile(pathMask)

#Reading path of raster files
rasterList<-list.files(path = raster_ini, pattern = "\\.bil", full.names = T)

#load rasters
rasters=lapply(rasterList, FUN = raster)

#cut each raster using the mask
for(rasterFile in rasters){
  
  cutting = raster::crop(rasterFile, MaskFile)
  OutFile<-paste(pathRasterClipped,names(rasterFile),".bil",sep="")
  
  raster::writeRaster(cutting,OutFile)
} 



# setting the path where the clipped raster will be saved
setwd(pathRasterClipped)


# selecting precipitation files and load
rain_files<-list.files(path =pathRasterClipped,  pattern = "^prec.*\\.bil$", full.names = T)
rain_rasters<-lapply(rain_files, FUN = raster)

#selecting mean temperature files and load
tmean_files<-list.files(path =pathRasterClipped,  pattern = "^tmean.*\\.bil$", full.names = T)
tmean_rasters<-lapply(tmean_files,FUN=raster)

#create raster stacks for analysis
wc_precf <- raster::stack(rain_rasters)
wc_tempf <-raster::stack(tmean_rasters)

# Load site or list of sites, file input format is a csv text file with header = x,y,filename. Columns are separated by commas. First column x is longitude value in decimal degrees, second column is latitude
# value in decimal degrees. Third column is name or code of site can be alphanumeric and will be used as a filename for the final tiff raster file output. 


FileOfSites<-read.csv('C:/Projectfolder/ClimateSimilarity/sites.csv',header = TRUE,sep = ",", stringsAsFactors = FALSE )  

#Path for saving raster outputs
path_out<-'C:/Projectfolder/ClimateSimilarity/analogues'
#Run analogues, this permits running all coordinate pairs representing sites of interest
# This example uses precipitation and average temperature as climate parameters. Both parameters are weighted equal, if you want to change weights towards either one adjust values keeping total at 1.0
#growing.season refers to the time frame which to compare. Set to (1,12) it will do the aanlysis for the whole 12 monhts of the year, if you want to run only for a specific number of months adjust accordingly
# Rainy season from April to October growing.season=c(4,10)


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
                              env.data.ref=list(wc_prec,wc_temp), env.data.targ=list(wc_precf,wc_tempf),
                              outfile=wd,fname=NA,writefile=FALSE)
  x <- calc_similarity(params)
  raster::crs(x) <- "+proj=longlat"
  rasterName_Similarity=paste0(raster_out, "Similarity",FileName,".tif")
  raster::writeRaster(x, filename =rasterName_Similarity , gdal="COMPRESS=NONE")
  gc()
  
}




# future climate data can be obtained from sources like worldclim (worldclim.org) which provides an ample amount of outpputs of a number of downscaled GCMs for different scenarios up to RCP 8.5.
# They can be downloaded and used just as the baseline worlclim data. 
# In case you want to use ensembles for montly data these can also be incorporated for the future scenarios. In this case they  were generated as an average of a number of worldclim datasets
# 

grids <- c('precf1.bil','precf2.bil','precf3.bil','precf4.bil','precf5.bil','precf6.bil','precf7.bil','precf8.bil','precf9.bil','precf10.bil','precf11.bil','precf12.bil')
gridst <- c('tmeanf1.bil','tmeanf2.bil','tmeanf3.bil','tmeanf4.bil','tmeanf5.bil','tmeanf6.bil','tmeanf7.bil','tmeanf8.bil','tmeanf9.bil','tmeanf10.bil','tmeanf11.bil','tmeanf12.bil')


wc_precf <- raster::stack(paste0("C:/rworkspace/rworldclim/wcft2-5/", grids))
wc_tempf <- raster::stack(paste0("C:/rworkspace/rworldclim/tmeanf/", gridst))
FileOfSites<-read.csv('C:/rworkspace/rworldclim/Sites3.csv',header = TRUE,sep = ",", stringsAsFactors = FALSE )   

#For running analogues with future data you have 3 options. Forward = comparing current to future, Backward comparing future to current and future vs future to see were you would find similar sites
# to your site of interest in the future. To apply the there options you switch the raster stacks in the expresion below : env.data.ref=list(wc_prec,wc_temp), env.data.targ=list(wc_precf,wc_tempf)
# with current in .ref and future data in .targ gives you the areas that will have the climate that your site has in the future. If you put fut in .ref and present in .targ you get the areas in the world
# were you can find your sites future climate today. This can be useful to see how agro climatic conditions will change, which crops are being grown and which type of cultivars would you need in your site to 
# adapt to climate change.


for (i in 1:nrow(FileOfSites))
{
  
  Long<-FileOfSites[i,1]
  Lat<-FileOfSites[i,2]
  FileName<-FileOfSites[i,3]
  print(FileName)
  
  params <-  createParameters(x=Long, y=Lat, vars=c("prec","tmean"), weights=c(0.5,0.5), ndivisions=c(12,12),
                              growing.season=c(1,12),rotation="tmean",threshold=1,
                              env.data.ref=list(wc_prec,wc_temp), env.data.targ=list(wc_precf,wc_tempf),
                              outfile=wd,fname=NA,writefile=FALSE)
  x <- calc_similarity(params)
  crs(x) <- "+proj=longlat"
  raster::writeRaster(x, filename = paste0(FileName, ".tif"), gdal="COMPRESS=NONE")
  gc()
    
}

#Output raster can be used for further analysis or mapping purposes in R or any GIS software
