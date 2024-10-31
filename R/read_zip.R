#' Unzip and extract CSV
#' @description
#'
#' Unzip a csv file from a raw response and transform into a data frame.
#' The archive must contain a csv, otherwise will return NULL.
#'
#'
#' @param raw_response the response of the get_content function
#' @returns data frame
#' @export



read_zip_pack <- function(raw_response) {
  temp_file <- tempfile(fileext = ".zip")
  writeBin(raw_response, temp_file)

  # get file size
  tryCatch(
    {
      info_list <- unzip(temp_file, list = TRUE)
    },
    error = function(c) {
      message(c)
      stop("Make sure you have downloaded a zip file", parent = c)
    }
  )
  kb <- format(round(sum(info_list$Length) / 1024, 0), big.mark = ",")
  message(stringr::str_c("\nThe size of the files to be extracted is ", kb, " KB"))

  file_list <- unzip(temp_file, list = FALSE)
  unlink(temp_file)

  if (length(file_list) != 1) {
    stop("The file contain zero or more than 1 file. No action will be taken")
  }

  df <- readr::read_csv(file_list[1], show_col_types = FALSE)
  unlink(file_list[1])

  return(df)
}
