#' Download raw data from a URL
#' @description
#' Designed to work with content in a binary form.
#'
#' @param url address of the site
#' @returns The binary body response
#' @export
#' @examples
#' get_raw_content("https://ipchem.jrc.ec.europa.eu/public/ESBUBA/2005/IPCHEM_ESBUBA_c3f8c698-52f2-408b-8138-35e5913a6029.zip")
#'
get_raw_content <- function(url) {
  tryCatch(
    {
      req <- httr2::request(url)
      resp <- httr2::req_perform(req)

      f_type <- httr2::resp_content_type(resp)

      # print(stringr::str_c("Expected file for download: ", f_type))
    },
    error = function(c) {
      message(c)
      message(paste("URL:", url))
      stop("The call has encountered an error. Make sure the URL is working",
        parent = c
      )
    }
  )

  resp_raw <- httr2::resp_body_raw(resp)

  # return(list("type" = f_type, "content" = resp_raw))

  return(resp_raw)
}


#' Download csv file from url
#' @description
#' Download a CSV file from a url and tranform it into a data frame.
#'
#' @param url the url must point to a csv file. return error otherwise
#' @returns dataframe object
#' @export
#' @examples
#' get_csv_content("https://ipchem.jrc.ec.europa.eu/public/IPCHEM_public_dataset_packages.csv")
#'
get_csv_content <- function(url) {
  if (!stringr::str_detect(url, "\\.csv$")) {
    message(paste("URL:", url))
    stop("Pass a URL for a CSV file. Ex. abc.com/data.csv")
  }

  tryCatch(
    {
      req <- httr2::request(url)
      resp <- httr2::req_perform(req)

      f_type <- httr2::resp_content_type(resp)

      # print(stringr::str_c("Expected file for download: ", f_type))
    },
    error = function(c) {
      message(c)
      message(paste("URL:", url))
      stop("The call has encountered an error. Make sure the URL is working",
        parent = c
      )
    }
  )

  resp_str <- httr2::resp_body_string(resp)

  df <- readr::read_csv(resp_str, show_col_types = FALSE)

  return(df)
}


#' Download json file from url
#' @description
#' Download a json file from a url and transform it into a list.
#'
#' @param url the url must point to a json file. return error otherwise
#' @returns list object
#' @export
#' @examples
#' get_json_content("https://ipchem.jrc.ec.europa.eu/public/AIRBASE/IPCheM_AIRBASE_metadata.json")
#'
get_json_content <- function(url) {
  if (!stringr::str_detect(url, "\\.json$")) {
    message(paste("URL:", url))
    stop("Pass a URL for a JSON file. Ex. abc.com/data.JSON")
  }

  tryCatch(
    {
      req <- httr2::request(url)
      resp <- httr2::req_perform(req)

      f_type <- httr2::resp_content_type(resp)

      # print(stringr::str_c("Expected file for download: ", f_type))
    },
    error = function(c) {
      message(c)
      message(paste("URL:", url))
      stop("The call has encountered an error. Make sure the URL is working",
        parent = c
      )
    }
  )

  resp_str <- httr2::resp_body_string(resp)

  jsn <- rjson::fromJSON(resp_str)

  return(jsn)
}
