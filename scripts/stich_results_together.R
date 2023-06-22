
#this function will take all single .rds trajectories in a folder and stich them together into one data frame.
rds_stich_together_whole_dir = function(folderdir, writefile = FALSE, conserve_attr = FALSE){
  filenames = setdiff(list.files(folderdir), list.dirs(folderdir, recursive = FALSE, full.names = FALSE))
  filepaths = paste0(folderdir, "/", filenames)
  filelist = lapply(filepaths, readRDS)
  
  
  #an option to conserve the metadata as columns. This makes it easier to compare different outputs
  add_attributes_as_columns = function(data){
    for(i in 4:(length(attributes(data)))){
      myattr_name = names(attributes(data))[i]
      myattr_val = attributes(data)[[i]]
      data = data %>%
        mutate(!!myattr_name := myattr_val)
    }
    return(data)
  }
  
  if (conserve_attr){filelist = lapply(filelist,add_attributes_as_columns)}
  
  #out = do.call("rbind",filelist) %>% data.table::as.data.table()
  out = data.table::rbindlist(filelist)
  
  if (writefile){
    message(paste0("Writing combined file to: ", folderdir,"/combined/"))
    message("\nNot returning file to environment. Chose <writefile = FALSE> if you want a combined file returned to the environment")
    #creating the batch_savedir, if it doesn't exist
    dir.create(paste0(folderdir,"/combined"), showWarnings = FALSE)
    saveRDS(out, file = paste0(folderdir,"/combined/run_combined.rds"))
    return(NULL)
  } else {
    return(out)
  }
}

library(tictoc)
tic()
foldername = "V1_montblanc"
#Usage
myfiledir = paste0(here::here(),"/batch_results/",foldername)

#myfiledir = "D:/SCRIPT_SHARE/HYSPLIT/latitude_belt_run_7000masl_comb_15,25"

myfile_df = rds_stich_together_whole_dir(myfiledir, FALSE, conserve_attr = FALSE)

savepath = paste0(myfiledir,"/batch_combined/")

#savepath = paste0(here::here(),"../../../SCRIPT_SHARE/HYSPLIT/",foldername)
dir.create(savepath, showWarnings = TRUE)
#savepath = paste0(savepath, "/df/")
#dir.create(savepath)

#saving in the shared folder
saveRDS(myfile_df, file = paste0(savepath,"run_combined.rds"))
toc()
