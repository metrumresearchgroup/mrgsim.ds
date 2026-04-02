#' Refresh 'Arrow' dataset pointers
#'
#' @description
#' Arrow dataset pointers become invalid when an object is created in a worker
#' process and returned to the head node (e.g. after a parallel simulation).
#' `refresh_ds()` rebuilds the pointer by re-opening the parquet files via
#' [arrow::open_dataset()] and updates `pid` and `dim` in place. Because
#' refreshing is itself the fix for an invalid pointer, it checks that files
#' exist but does not call `safe_ds()` first.
#'
#' @param x an mrgsimsds object or a list of objects.
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
#' When `x` is an mrgsimsds object, it is returned invisibly with its Arrow
#' pointer, `pid`, and `dim` refreshed in place.
#'
#' When `x` is a list, it is returned invisibly with `refresh_ds()` applied to
#' every mrgsimsds element; non-mrgsimsds elements are left unchanged.
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
