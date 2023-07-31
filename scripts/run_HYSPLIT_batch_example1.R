library(splitr) #hysplit interface
library(lubridate) #date time sequences
library(data.table) #crunching
library(dplyr) #crunching
library(tidyr) #crunching
library(rstudioapi) #for job controls -> parallel processing
library(here) #neat relative paths

######## USER INPUT ###############
job_metdir = paste0(here::here(),"/meteo_input/met_ncar_ncep") #this is the directory where the meteo-input files are found.
batch_savedir = paste0(here::here(),"/batch_results/Ex1_AMS") #This is the directory where the results are saved.
job_workdir = paste0(here::here(),"/job_workdir") #this is the directory where the jobs will be "working". 

output_filetype = "rds" #filetype of final HYSPLIT output. Either "rds" or "csv" 

jobnumber = 4 #this gives the number of jobs, and thus the number of paralell processes. 

###################################################
#You now want to create a "run control_datatable", where each row contains the information for one hysplit run. The names must be exactly the following
#As such, it has to contain the following columns:
#
# met_type : <string>  which meteo file to use. Can be "gdas1", but also "reanalysis". In theory also "gdas0.5", and "gfs0.25 but I didn't test this. (See ?splitr::hysplit_trajectory for more info)
# run_direction : <string> one of <c("forward","backward")> . Direction of the run.
# extended_met : <boolean> TRUE if you want extra information from the meteo file passed to the output file (for example, RH, theta), FALSE otherwise
# lon :  <numerical> longitude of emission  [-180 deg to 180 deg format]
# lat :  <numerical> latitude of emission [-90 deg to 90 deg format]
# days_to_run : <Date> The date of the run. for example: as.Date(c("2014-10-01")) --> run on 2014.10.01
# starting_height : <numerical> starting height of emission
# run_duration : <numerical> run duration in hours. For example, 240 would mean run the trajectory for 10 days.
# starting_hours : <list> a list containing one vector of the starting hours where to compute the trajectories. For example: list(c(0,6,12,18)) would mean to run one trajectory every 6 hours of the respective day.

###################################################
control_datatable = expand.grid(lon = c(77.56667),
                                lat = c(-37.8),
                                # lat = 45.76583,
                                # lon = 	6.864722,
                                starting_height=c(50),
                                days_to_run = seq.Date(as.Date("2016-07-09"), as.Date("2016-07-12"), by = "1 day")) %>%
  dplyr::mutate(met_type = "reanalysis", #the meteo input. Make sure that job_metdir points to the right direction!
                run_direction = "backward",
                extended_met = FALSE,
                run_duration = 4*24, #in hours
                starting_hours = list(seq(0,23,1)))


job_config = set_config(kmsl = 0) #if kmsl = 0, interpret height input as "above ground level", if kmsl = 1, interpret it as "above sea level"

#Note that if you want to change other advanced inputs for the HYSPLIT model, you can also do that by adding the right flag to the job_config via the
#set_config() function fromsplitr. See ?splitr::set_config for further details. 





###################### NO MODIFICATIONS BELOW SHOULD BE NECESSARY###############

#creating the directories, if they don't exist
dir.create(paste0(here::here(),"/batch_results"), showWarnings = FALSE)
dir.create(batch_savedir, showWarnings = FALSE)
dir.create(job_workdir, showWarnings = FALSE)

#Trajectories might take on average longer for certain time periods than for others. To assure that all jobs finish at approximately the same time,
#we can give each job a random subset of all trajectories
set.seed(42)
indexlist = split(sample(1:nrow(control_datatable)), sort((1:nrow(control_datatable)) %% jobnumber))

#######################

# Running stuff now. Multiple "jobs" will be opened in Rstudio to enable parallel computing (works on windows). 
# Each job will get a part of the control_datatable as instructions to calculate corresponding trajectories.
# Each job will "call" the main calculation script, which is given in the "workingscript_path" variable. 

workingscript_path = "./scripts/localjob_datatable_run.R"
jobs = 1:jobnumber %>% as.character()%>%paste0("j",.)

#launch all the jobs.
for (i in 1:jobnumber){
  currentjob = jobs[i]
  job_data_table = control_datatable[indexlist[[i]],]
  rstudioapi::jobRunScript(path = workingscript_path , importEnv = TRUE)
}
