#' Refresh 'Arrow' dataset pointers
#' 
#' Pointers to arrow data sets will be invalid when the simulation is run in a 
#' different process, for example when simulating in parallel. The pointers
#' should be refreshed on the head node once the simulation is finished. 
#' 
#' @param x an mrgsimsds object. 
#' @param ... for future use.
#' 
#' @examples
#' mod <- house_ds()
#' 
#' data <- ev_expand(amt = 100, ID = 1:100)
#' 
#' out <- lapply(1:3, function(rep) {
#'   mrgsim_ds(mod, data) 
#' })
#' 
#' refresh_ds(out)
#' 
#' @return
#' The mrgsimsds object is returned invisibly with pointers refreshed; 
#' modification is made in place. 
#' 
#' @details
#' To refresh the pointers, `refresh_ds()` checks that the files still exist
#' and passes the file list to [arrow::open_dataset()]. The object `pid` and 
#' the `dim` attributes are also refreshed, after re-opening the data set.
#' 
#' @rdname refresh_ds
#' @export
refresh_ds <- function(x, ...) UseMethod("refresh_ds")
#' @rdname refresh_ds
#' @export
refresh_ds.mrgsimsds <- function(x, ...) {
  check_files_fatal(x)
  x$ds <- open_dataset(x$files)
  x$files <- x$ds$files
  x$dim <- dim(x$ds)
  x$pid <- Sys.getpid()
  invisible(x)
}

#' @rdname refresh_ds
#' @export
refresh_ds.list <- function(x, ...) {
  classes <- simlist_classes(x)
  x[classes] <- lapply(x[classes], refresh_ds)
  invisible(x)
}
