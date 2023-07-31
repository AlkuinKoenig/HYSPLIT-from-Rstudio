#This is the main script that each of the individual jobs will run

library(splitr.bugfix) #HYSPLIT interface

#handling of common errors
myerror = dplyr::case_when(!(output_filetype %in% c("rds","csv")) ~ paste0(output_filetype, " is not an accepted type for output data output data"),
                           !dir.exists(job_metdir) ~ paste0("meteo input directory ", job_metdir," doesn't exist"),
                           !dir.exists(batch_savedir) ~ paste0("directory for output ", batch_savedir," doesn't exist"),
                           !dir.exists(job_workdir) ~ paste0("job working directory ", job_workdir, " doesn't exist"),
                           nrow(job_data_table)==0 ~ "empty input data table - nothing to compute",
                           1==1 ~ "no error"
)

#a function to add some metadata as attributes. Will only be helpful if you chose "rds" as output.
add_metadata_attributes = function(data,
                                   run_direction = NULL,
                                   extended_met = NULL,
                                   starting_height = NULL,
                                   meteofile = NULL){
  attr(data, "run_direction") = run_direction
  attr(data, "extended_met") = as.character(extended_met)
  attr(data, "starting_height") = as.character(starting_height)
  attr(data, "meteofile")  = as.character(meteofile)
  return(data)
}

if (myerror != "no error"){message(paste0("ERROR: ", myerror," ... aborting"))
} else #only run if no error.
{
  for (i in 1:nrow(job_data_table)){
    message(paste0("Calculating day ", i,"/", nrow(job_data_table),": ", job_data_table$days_to_run[i]," at starting hours: ", paste(job_data_table$starting_hours[[i]], collapse=",")))
    
    #creating a new working directory from scratch on every run. The reason is to avoid one error making whole batch get "stuck"
    temp_workdir = paste0(job_workdir, "/", currentjob)# paste0(currentjob, "-row",i))
    unlink(temp_workdir, recursive = TRUE)
    dir.create(temp_workdir, showWarnings = FALSE)
    
    trajectory<-
      hysplit_trajectory(
        lat = job_data_table$lat[i],
        lon = job_data_table$lon[i],
        height = job_data_table$starting_height[i],
        duration = job_data_table$run_duration[i],
        days = job_data_table$days_to_run[i],
        daily_hours = job_data_table$starting_hours[[i]],
        direction = job_data_table$run_direction[i],
        met_type = job_data_table$met_type[i],
        extended_met = job_data_table$extended_met[i],
        exec_dir = temp_workdir,
        met_dir = job_metdir, #passed to the job from global environment
        config = job_config,#passed to the job from global environment
        clean_up = TRUE
      )
    
    
    filename = paste(job_data_table$met_type[i], job_data_table$run_duration[i], job_data_table$lat[i], job_data_table$lon[i], job_data_table$starting_height[i],
                     "X", job_data_table$days_to_run[i],"X", paste(job_data_table$run_duration[i],collapse=""),"Y",
                     paste(job_data_table$starting_hours[[i]], collapse = ""),
                     substr(as.character(job_data_table$extended_met[i]),1,1), currentjob, sep = "_")
    
    
    trajectory = add_metadata_attributes(trajectory, job_data_table$run_direction[i], job_data_table$extended_met[i], job_data_table$starting_height[i], job_data_table$met_type[i])
    
    message(paste0("\tSaving under: ",filename,".", output_filetype))
    if (output_filetype == "rds"){
      saveRDS(trajectory,paste0(batch_savedir, "/", filename, ".", output_filetype))
    } else if (output_filetype=="csv"){
      write.table(trajectory, paste0(batch_savedir, "/", filename, ".", output_filetype ),
                  col.names=TRUE, row.names=FALSE, sep = ",", dec = ".", quote=FALSE)
    }
    
    unlink(temp_workdir, recursive=TRUE)#cleanup
  }#for
}#else
message(paste0("\n",currentjob, " finished"))