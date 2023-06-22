#This script allows you to download the meteorological input for your runs (by leveraging a function that is already included in splitR). 
#Before doing any runs with parallel-processing, you should make sure to have all meteo files already available. 
#The script will download the files only when they are not already in the folder you specify

#Please note: If you do forward or backward runs of long duration, make sure that the
#"startdate" and "enddate" below are sufficiently generously chosen. 

####################USER INPUT#################
startdate = as.Date("2016-07-05")
enddate = as.Date("2016-07-15")

#where you want to save the files
meteo_output_dir = paste0(here::here(),"/meteo_input/met_ncar_ncep")

#the type of meteorological input. "reanalysis" for ncar/ncep, other options are
#"gdas1" and "gdas0.5". Note that "gfs0.25" is currently not working as option 
#for the automatic download. You'll have to get it from ftp://arlftp.arlhq.noaa.gov/archives/ yourself. 
meteo_type = "reanalysis" 
#######################END user input##############



workdir = paste0(here::here(),"/job_workdir/meteo_download")
datevec = seq.Date(startdate,enddate, by = "1 day")
dir.create(workdir)
dir.create(meteo_output_dir)

system.time(
  trajectory <-
    splitr::hysplit_trajectory(
      lat = -16.35023,
      lon = -68.13143,
      height = 2300,
      duration = 1,
      days = datevec,      
      exec_dir = workdir,
      daily_hours = 1,
      direction = "backward",
      met_type = meteo_type,
      extended_met = TRUE,
      met_dir = meteo_output_dir,
    )
)
