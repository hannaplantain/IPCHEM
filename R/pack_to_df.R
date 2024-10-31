#' Utility to download a data frame from url
#'
#' @description
#' Using a url, download the content zip or csv and transform it into a data frame.
#'
#' @param url character; the address where the table or zip file exists
#' @param exp_jsn logical. expand json string if found in the data frame
#' @param json_col if data frame is provided, specify column where json resides
#' @param keep_nodes subset the nodes from json. vector or single value
#' @returns data frame
#'
#' @export
#'
#' @examples
#' url_to_df("https://ipchem.jrc.ec.europa.eu/public/ESBUBA/2005/IPCHEM_ESBUBA_c3f8c698-52f2-408b-8138-35e5913a6029.zip")
#'
url_to_df <-
  function(url,
           exp_jsn = FALSE,
           json_col = NULL,
           keep_nodes = NULL) {
    suffix <- get_url_suffix(url)

    if (suffix == "csv") {
      df <- get_csv_content(url)
    } else if (suffix == "zip") {
      raw_content <- get_raw_content(url)

      df <- read_zip_pack(raw_content)
    } else {
      stop("The url must point to a zip or csv file")
    }

    if (exp_jsn) {
      if (is.null(json_col)) {
        stop("Provide a json_col if exp_jsn is TRUE")
      } else {
        if (!(json_col %in% colnames(df))) {
          stop("json_col is not in the table")
        } else {
          df <- expand_json(df, json_col = json_col, keep_nodes = keep_nodes)
        }
      }
    }

    return(df)
  }


#' Wrapper for url_to_df for multiple urls
#'
#' @description
#' Loops over a series of urls, download the content zip or csv and transform it into a data frame.
#'
#' @param urls list, vector or character. the addresses where the tables or zip file exists
#' @param exp_jsn logical. expand json string if found in the data frame
#' @param json_col if data frame is provided, specify column where json resides
#' @param keep_nodes subset the nodes from json. vector or single value
#' @returns list of data frames
#'
#' @export
#'
#' @examples
#' url1 <- "https://ipchem.jrc.ec.europa.eu/public/EMPODAT/2015/IPCHEM_EMPODAT_a008a910-dda6-4e0d-a298-014c6eb1973c.zip"
#' url2 <- "https://ipchem.jrc.ec.europa.eu/public/EMPODAT/2016/IPCHEM_EMPODAT_c0ee2c5e-16c6-45c5-a572-dbf04d5abf26.zip"
#'
#' ls_url <- c(url1, url2)
#'
#' urls_to_df(ls_url)
#'
urls_to_df <- function(urls,
                       exp_jsn = FALSE,
                       json_col = NULL,
                       keep_nodes = NULL) {
  # browser()
  urls <- unlist(urls)
  n <- length(urls)
  df_list <- list()

  if (n > 1) {
    urls <- unlist(urls)
    message(stringr::str_c("\nThere are", n, "urls in the list", sep = " "))

    for (i in seq_along(urls)) {
      url <- urls[i]

      df_name <- get_url_suffix(gsub(stringr::str_c(".", get_url_suffix(url)), "", url))

      df <- url_to_df(
        url,
        exp_jsn = exp_jsn,
        json_col = json_col,
        keep_nodes = keep_nodes
      )

      df_list[[df_name]] <- df
    }

    return(df_list)
  } else {
    df_name <- get_url_suffix(gsub(stringr::str_c(".", get_url_suffix(urls)), "", urls))

    df <- url_to_df(
      urls,
      exp_jsn = exp_jsn,
      json_col = json_col,
      keep_nodes = keep_nodes
    )

    df_list[[df_name]] <- df

    return(df_list)
  }
}


#' Download one or multiple URLs
#'
#' @description
#' Loops over a series of urls, download the content zip or csv and transform it into a data frame.
#'
#' @param urls list, vector or character. the addresses where the tables or zip file exists
#' @param exp_jsn logical. expand json string if found in the data frame
#' @param json_col if data frame is provided, specify column where json resides
#' @param keep_nodes subset the nodes from json. vector or single value
#' @returns list of data frames
#'
#' @export
#'
#' @examples
#' url1 <- "https://ipchem.jrc.ec.europa.eu/public/EMPODAT/2015/IPCHEM_EMPODAT_a008a910-dda6-4e0d-a298-014c6eb1973c.zip"
#' url2 <- "https://ipchem.jrc.ec.europa.eu/public/EMPODAT/2016/IPCHEM_EMPODAT_c0ee2c5e-16c6-45c5-a572-dbf04d5abf26.zip"
#'
#' ls_url <- c(url1, url2)
#'
#' download_files(ls_url)
#'
download_files <- function(urls,
                           exp_jsn = FALSE,
                           json_col = NULL,
                           keep_nodes = NULL) {
  if (length(urls) == 0) {
    stop("The URL list has length zero")
  }

  if (length(urls) == 1) {
    urls <- unlist(urls, use.names = FALSE)
    res <- url_to_df(urls, exp_jsn = exp_jsn, json_col = json_col, keep_nodes = keep_nodes)
    return(res)
  } else {
    res <- urls_to_df(urls, exp_jsn = exp_jsn, json_col = json_col, keep_nodes = keep_nodes)
    return(res)
  }
}
