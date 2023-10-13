#' Read HYSPLIT trajectory output files into a data frame
#'
#' The function takes HYSPLIT trajectory output files in a specified output
#' directory and processes all files into a data frame object.
#'
#' Modified by AMK the 2023/10/13 for compatibility with newest HYSPLIT versions.
#' @param output_folder The path of the directory containing the trajectory
#'   endpoints files.
#' @return A tibble with HYSPLIT trajectory data.
#' @examples
#' \dontrun{
#' # Process all trajectory output files in the
#' # specified output directory
#' trajectory_df <-
#'   trajectory_read(
#'     output_folder = "traj--2015-06-16--23-58-44")
#' }
#' @export
trajectory_read <- function(output_folder) {  
  
  # Get file list for trajectories from the specified folder
  trajectory_file_list <- 
    list.files(
      path = output_folder,
      pattern = "^traj-.*"
    )
  
  # Initialize empty tibble with 12 columns
  traj_tbl <-
    dplyr::tibble(
      receptor = integer(0),
      year = integer(0),
      month = integer(0),
      day = integer(0),
      hour = integer(0),
      hour_along = integer(0),
      lat = numeric(0),
      lon = numeric(0), 
      height = numeric(0),
      pressure = numeric(0),
      traj_dt = lubridate::as_datetime("2015-01-01")[-1],
      traj_dt_i = lubridate::as_datetime("2015-01-01")[-1]
    )
  
  extended_col_names <- 
    c(
      "year", "month", "day", "hour", "hour_along",
      "lat", "lon", "height", "pressure",
      "theta", "air_temp", "rainfall", "mixdepth", "rh", "sp_humidity", 
      "h2o_mixrate", "terr_msl", "sun_flux"
    )
  
  standard_col_names <- 
    c(
      "year", "month", "day", "hour", "hour_along",
      "lat", "lon", "height", "pressure"
    )
  
  # Process all trajectory files
  for (file_i in trajectory_file_list) {
    
    file_i_path <- file.path(output_folder, file_i)
    
    file_lines <- readLines(file_i_path, encoding = "UTF-8", skipNul = TRUE)
    
    file_one_line <- readr::read_file(file_i_path)
    
    header_line <- 
      file_lines %>%
      vapply(
        FUN.VALUE = logical(1),
        USE.NAMES = FALSE,
        function(x) tidy_grepl(x, "PRESSURE")
      ) %>%
      which()
    
    file_lines_data <- 
      file_lines[(header_line + 1):(length(file_lines))] %>%
      tidy_gsub("\\s\\s*", " ") %>%
      tidy_gsub("^ ", "")
    
    #AMK making this compatible with newer versions. I'm going a different route here. Spllitting each line into elements
    file_lines_data = lapply(file_lines_data, function(x){strsplit(x," ")})
    
    #check if all lines have the same number of entries (through the variance of length). If that's not the case, there is a line break breaking a data line in 2
    total_entries_per_line = unique(sapply(file_lines_data,function(x){unlist(x)%>%length}))
    if (length(total_entries_per_line) > 1 ){
      warning(paste0("data lines of different length detected: ", paste(total_entries_per_line, collapse = " and "),". Reorganizing."))
    }
    #we know how many elements we expect per line, so we can just convert the results into a matrix and move on from there. 
    traj.matrix = unlist(file_lines_data)%>%as.numeric()%>%matrix(ncol=sum(total_entries_per_line),byrow=TRUE)
    
    #we can drop those columns that we know are "empty"
    separator_columns = c(1,2,7,8)
    traj.tibble = traj.matrix[, setdiff(1:sum(total_entries_per_line), separator_columns)] %>% as_tibble(.name_repair = "minimal")
    
    #now setting the right amount of row names, depending on whether we are using extended meteo or not. 
    data_entries_per_line = sum(total_entries_per_line) - length(separator_columns)
    
    if (data_entries_per_line == 9){
      names(traj.tibble) = standard_col_names
    } else if (data_entries_per_line == 18){
      names(traj.tibble) = extended_col_names
    } else {
      warning(paste0("I expected either 9 (standard output) or 18 (extended meteo output) different entries per trajectory, but I found ",data_entries_per_line, "! 
                     I'll probably crash now. Bye!" ))
    }
    
    #final massaging and done
    traj.tibble=traj.tibble%>%
      dplyr::mutate(year_full = ifelse(year < 50, year + 2000, year + 1900)) %>%
      tidyr::unite(col = date_str, year_full, month, day, sep = "-", remove = FALSE) %>%
      tidyr::unite(col = date_h_str, date_str, hour, sep = " ", remove = FALSE) %>%
      dplyr::mutate(traj_dt = lubridate::ymd_h(date_h_str)) %>%
      dplyr::select(-c(date_h_str, date_str, year_full)) %>%
      dplyr::mutate(traj_dt_i = traj_dt[1])
    
    traj_tbl <- traj_tbl %>% dplyr::bind_rows(traj.tibble)
  }
  
  traj_tbl
}
