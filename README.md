# SpatialAnalogues
R scripts and workflows for spatial analogue modeling and foresight analysis oriented towards disease risk mapping or climate change analogues. 
Purpose of the analogue tools is to do analysis on climate similarity for specific or a number of sites to identify areas for scaling of tecnologies like crop varieties. The similarity analysis can be both done for current climate but also for future climate scenarios both back ward and forward. This allows users to identify areas that nowadays already have a climate similar to the climate our site is predicted to have in the future. Potential uses are for example to survey those areas for varieties used with specific adaption traits or to check genebank holdings for accessions that were collected in those areas and might be interesting for breeding programs working towards stress tolerance.
Or it can be used to see which areas my current site of work represents in the future which can allow us to identify. Other potential uses are creation of risk maps for diseases. If quality gridded data is available for other parameters like soil characteristics relevant to plant suitability eg pH, or socio economic indicators like market access this can be used to also to identify    

To set up analogues in the R environment a number of libraries has to be installed and amongst them the analogues one which is not part of the CRAN repository.

install.packages("remotes")
remotes::install_github("CIAT-DAPA/analogues")
see details on https://github.com/CIAT-DAPA/analogues/


For the base version we use the worldlcim data set: Fick, S.E. and R.J. Hijmans, 2017. WorldClim 2: new 1km spatial resolution climate surfaces for global land areas. International Journal of Climatology 37 (12): 4302-4315. 
This one of the most common used scientific data sets and exists at differnt resolutions depending on your geographical area 
