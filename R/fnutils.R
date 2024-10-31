#' Standardize names
#' @description
#' Create clean and ease to use names. Replaces punctuation with underscore and brings to lower.
#'
#' @param nm vector with column names or any other values
#' @returns vector of same length as input
#' @export
#' @examples
#' clean_name(c("First.col", "second col"))
#'
clean_name <- function(nm) {
  if (is.null(nm)) {
    return(NULL)
  } else if (!is.character(nm)) {
    stop("Input must be a character vector")
  } else {
    return(stringr::str_to_lower(
      stringr::str_replace(
        stringr::str_replace_all(
          nm,
          "[\\s]|\\.{1,}|-{1,}|\\,{1,}|_{2,}", "_"
        ),
        "_{2,}",
        "_"
      )
    ))
  }
}

#' Standardize col names of a data frame
#' @description
#' Create clean and ease to column names. Replaces punctuation with underscore and brings to lower.
#'
#' @param df data frame to prettify col names
#' @returns same data frame with new col names
#' @export
#' @examples
#' chg_col_names(data.frame("first.col" = c(1, 2), "second col" = c(3, 4)))
#'
chg_col_names <- function(df) {
  names(df) <- sapply(names(df), clean_name, USE.NAMES = FALSE)
  return(df)
}

#' Parse ellipsis
#' @description
#' Transform arguments into a list.
#' Unnamed arguments are eliminated.
#' If a data frame is argument, each column will become a list.
#'
#' @param ... vector, list, data frame
#' @returns a list of arguments
#' @export
#' @examples
#' expand_args(x = c("a", "b"), c(2), data.frame("col1" = c(1, 2)))
#'
expand_args <- function(...) {
  arg_list <- list(...)
  new_list <- list()

  for (i in seq_along(arg_list)) {
    if (is.null(names(arg_list[i]))) {
      # if one element has name, those without names have ""

      if (is.data.frame(arg_list[[i]])) {
        new_list <- append(new_list, as.list(arg_list[[i]]))
      } else {
        cat(
          "Argument number ",
          i,
          " is unamed and is not a dataframe. Skipping...\n"
        )
      }
    } else if (names(arg_list[i]) == "") {
      if (is.data.frame(arg_list[[i]])) {
        new_list <- append(new_list, as.list(arg_list[[i]]))
        # print(as.list(arg_list[[i]]))
      } else {
        cat(
          "Argument number ",
          i,
          " is unamed and is not a dataframe. Skipping...\n"
        )
      }
    } else {
      new_list <- append(new_list, arg_list[i])
    }
  }

  return(new_list)
}

#' Prettify a vector of values
#' @description
#' Prints the elements in alphabetical order with index letter.
#'
#' @param v vector of values
#' @returns NULL
#' @export
#' @examples
#' pprint_vect(c("Gabriel", "Inzaghi"))
#'
pprint_vect <- function(v) {
  avail_let <- unique(sapply(v, function(x) {
    stringr::str_sub(x, 1, 1)
  }, USE.NAMES = FALSE))

  nice_list <- list()

  for (let in avail_let) {
    for (dat in v) {
      if (stringr::str_sub(dat, 1, 1) == let) {
        nice_list[[let]] <- c(nice_list[[let]], dat)
      }
    }
  }

  for (i in seq_along(nice_list)) {
    let <- names(nice_list[i])
    vls <- nice_list[[i]]

    cat("-----", let, "-----\n")
    cat(vls, "\n\n", sep = " | ")
  }
}

#' Show url last part
#'
#' @description
#' Extract the last part of an url, that being and extension or just folder path.
#'
#' @param url character
#' @returns character; sufix
#'
#' @export
#'
#' @examples
#' get_url_suffix("abc.com/file.csv")
#'
get_url_suffix <- function(url) {
  cleaned_url <- gsub("^https?://", "", url, ignore.case = TRUE)

  url_parts <- unlist(strsplit(cleaned_url, "/"))

  last_part <- tail(url_parts, 1)

  suffix <- sub(".*\\.", "", last_part)

  return(suffix)
}

#' Check if a pattern is in a string
#'
#' @description
#' Used in filter argument for retrieve_info or equivalent function
#'
#' @param var string, vector of strings, list of strings
#' @param pattern string, vector of strings, list of strings. Not regular expressions.
#' @param type string; "any" or "all". Check if any or all values from pattern are part of var.
#' @returns bool; vector of equal length as var
#'
#' @export
#'
#' @examples
#' isin("abc", "a")
#'

isin <- function(var, pattern, type = "any"){

  pattern <- unlist(pattern, use.names = FALSE)

  if (type == "any"){
    pattern = stringr::str_c(pattern, collapse = "|")
  }else if (type == "all"){
    pattern = stringr::str_c(pattern, collapse = ".*)(.*")
    pattern = stringr::str_c("(.*", pattern, ".*)")
  }else{
    stop("Invalid type. Must be 'any' or 'all'")
  }

  found <- stringr::str_detect(var, pattern)

  return(found)
}
