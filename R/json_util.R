#' Parse json into data frame
#' @description
#'
#' Explode a json text stored in a vector or a columns from data frame.
#' If part of a data frame, the nodes will be transformed in columns.
#'
#' @param object a data frame or a vector that contains json files
#' @param json_col if data frame is provided, specify column where json resides
#' @param keep_nodes subset the nodes from json. vector or single value
#' @returns data.table
#' @export
#'
#' @examples
#' df <- data.frame("x" = c(1), "y" = c("{\"a\": 1, \"b\": 2}"))
#' expand_json(df, json_col = "y")
expand_json <- function(object, json_col = NULL, keep_nodes = NULL) {
  if (is.data.frame(object)) {
    if (is.null(json_col)) {
      stop("The object is a dataframe. Provide a column name where the json files are")
    } else {
      if (!(json_col %in% names(object))) {
        stop(stringr::str_c(json_col, "is not among the columns of the dataframe", sep = " "))
      }

      json_vect <- object[[json_col]]
      object[[json_col]] <- NULL
      isdf <- 1
    }
  } else if (is.vector(object)) {
    json_vect <- object
    isdf <- 0
  }

  n <- length(json_vect)
  step <- max(1, as.integer(n / 10))
  pb <- txtProgressBar(
    min = 0,
    max = n,
    initial = 0,
    char = "=",
    width = 30,
    style = 3
  )

  name_list <- names(rjson::fromJSON(json_vect[1])) # the first json dictates

  if (!is.null(keep_nodes)) {
    msk <- name_list %in% keep_nodes
    name_list <- name_list[msk]
    if (!any(msk)) {
      stop("Cannot not find any of keep_nodes in json")
    }
  }

  record_list <- list()
  i <- 0

  for (rec in json_vect) {
    rec <- rjson::fromJSON(rec)
    rec <- lapply(rec, function(x) {
      ifelse(is.null(x), NA, x)
    })

    for (nm in name_list) {
      if (is.null(rec[[nm]])) {
        record_list[[nm]] <- c(record_list[[nm]], NA)
      } else {
        record_list[[nm]] <- c(record_list[[nm]], rec[[nm]])
      }
    }

    i <- i + 1
    if (i %% step == 0) {
      setTxtProgressBar(pb, i)
    }
  }

  if (isdf == 1) {
    object <- data.table::as.data.table(object)
    data.table::setDT(record_list)

    object <- cbind(object, record_list)

    return(as.data.frame(object))
  } else {
    return(as.data.frame(data.table::as.data.table(record_list)))
  }
}

#' Show json structure
#' @description
#' Expand and show the json structure in an easy to use and see format.
#' @param jsn a string in json format
#' @param pprint show a nice print of the json
#' @returns data frame with information
#' @export
#'
#' @examples
#' jsn <- "{\"a\": 1, \"b\": \"horse\"}"
#' json_to_df(jsn, pprint = TRUE)
#'
json_to_df <- function(jsn, pprint = FALSE) {
  rec <- rjson::fromJSON(jsn)

  rcc <- list()

  for (i in seq_along(rec)) {
    rcc[[names(rec[i])]] <- c()

    if (typeof(rec[[i]]) == "list") {
      rcc[[names(rec[i])]] <- c("...", typeof(rec[[i]]))
    } else {
      rcc[[names(rec[i])]] <- c(rec[[i]], typeof(rec[[i]]))
    }
  }

  rec <- rcc

  if (pprint) {
    for (i in seq_along(rec)) {
      cat("Key: ", names(rec[i]), "\n")
      cat("\tvalue: ", rec[[i]][1], "\n")
      cat("\ttype: ", rec[[i]][2], "\n")
    }
  }

  nodes <- names(rec)

  cln <- stringr::str_c("node", seq(1, length(nodes)), sep = "_")

  lst <- list()

  for (i in seq_along(rec)) {
    lst[[cln[i]]] <- c(nodes[i], rec[[i]][1], rec[[i]][2])
  }

  df <- data.frame(lst)

  rownames(df) <- c("node", "value", "type")

  return(df)
}
