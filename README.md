# HYSPLIT-from-Rstudio
Scripts to calculate HYSPLIT trajectories from within Rstudio using the "splitR" library from Rich Iannone (https://github.com/rich-iannone/splitr) and making use of "Rstudio jobs" for a parallel computing solution that works on all operating systems. 

Several example scripts are provided. Check out the *.docx tutorial for more information.


#UPDATE 2023-10-13:
Included the newest (openly) available HYSPLIT version for LINUX and WINDOWS (still the older version for MAC, couldn't easily find an executable). As there was a slight change in the format of the raw HYSPLIT output in the newer version that broke the trajectory_read function in splitr, I had to modify the splitr library further (all modifications found in splitr.bugfix).
