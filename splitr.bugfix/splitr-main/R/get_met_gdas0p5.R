#' Get GDAS0.5 meteorology data files
#'
#' Downloads GDAS0.5 meteorology data files from the NOAA FTP server and saves
#' them to a specified folder. Files can be downloaded by specifying a list of
#' filenames (in the form of `"{YYYY}{MM}{DD}_gdas0p5"`).
#' 
#' @inheritParams get_met_gdas1
#' 
#' @export
get_met_gdas0p5 <- function(days,
                            duration,
                            direction,
                            path_met_files) {
  
  get_daily_filenames(
    days = days,
    duration = duration,
    direction = direction,
    suffix = "_gdas0p5"
  ) %>%
    get_met_files(
      path_met_files = path_met_files,
      ftp_dir = "ftp://arlftp.arlhq.noaa.gov/archives/gdas0p5"
    )
}
