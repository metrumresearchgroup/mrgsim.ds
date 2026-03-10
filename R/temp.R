#' Manage simulated outputs in the per-session temporary directory
#' 
#' Note: `purge_temp()` should not be needed or used in routine usage when 
#' simulation output objects are subject to the garbage collector. If you 
#' run `purge_temp()` with active objects pointing to those files, you will 
#' get an error when trying to access the data.
#' 
#' @param quietly if `TRUE`, messages will be suppressed.
#' @param ... objects whose files will be retained.
#' 
#' @return 
#' `list_temp()` returns a vector of file names. Other functions return `NULL`.
#' All return values are invisible.
#' 
#' @examples
#' mod <- house_ds()
#' 
#' out <- lapply(1:10, \(x) mrgsim_ds(mod))
#' 
#' list_temp()
#' 
#' sims <- reduce_ds(out)
#' 
#' list_temp()
#' 
#' retain_temp(sims)
#' 
#' list_temp() 
#' 
#' purge_temp() 
#' 
#' list_temp()
#' 
#' @export
list_temp <- function(quietly = FALSE) {
  temp <- list.files(tempdir(), pattern = .global$file.re, full.names = TRUE)
  if(isTRUE(quietly)) {
    return(invisible(temp))
  }
  if(!length(temp)) {
    message("No files in tempdir.")
    return(invisible(temp))
  }
  size <- total_size(temp)
  if(length(temp) < 6) {
    show <- paste0("- ", basename(temp))
  } else {
    show <- c(
      paste0("- ", basename(head(temp, n = 2))), 
      "   ...", 
      paste0("- ", basename(tail(temp, n = 2)))
    )
  }
  header <- paste0(length(temp), " files [", size, "]")
  cat(c(header, show), sep = "\n")
  return(invisible(temp))
}

#' @rdname list_temp
#' @export
retain_temp <- function(..., quietly = FALSE) {
  x <- list(...)
  cl <- simlist_classes(x)
  x <- x[cl]
  files <- lapply(x, \(xi) xi$files)
  files <- unlist(files, use.names = FALSE)
  temp <- list.files(tempdir(), pattern = .global$file.re, full.names = TRUE)
  temp <- temp[!(basename(temp) %in% basename(files))]
  unlink(x = temp, recursive = TRUE)
  if(!isTRUE(quietly)) {
    message("Discarding ", length(temp), " files.")
  }
  return(invisible(NULL))
}

#' @rdname list_temp
#' @export
purge_temp <- function(quietly = FALSE) {
  temp <- list.files(tempdir(), pattern = .global$file.re, full.names = TRUE)
  unlink(x = temp, recursive = TRUE)
  if(!isTRUE(quietly)) {
    message("Discarding ", length(temp), " files.")
  }
  return(invisible(NULL))
}
