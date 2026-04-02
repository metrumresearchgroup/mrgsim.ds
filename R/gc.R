#' Set collection status for mrgsimsds objects
#'
#' Controls whether the underlying parquet files are automatically deleted
#' when the object is garbage collected. Set `value = FALSE` to protect files
#' from cleanup; set back to `TRUE` to re-enable automatic deletion.
#'
#' @param x a list of mrgsimsds objects or a single mrgsimsds object.
#' @param value logical; if `TRUE` the underlying files will be cleaned up.
#' @param notify logical; if `TRUE` a message will be issued when files are 
#' cleaned up; this is intended for debugging or troubleshooting purposes.
#' @param ... not used.
#' 
#' @examples
#' mod <- modlib_ds("popex", outvars = "IPRED")
#' 
#' data <- ev_expand(amt = 100, ID = 1:5)
#' 
#' out <- mrgsim_ds(mod, data)
#' 
#' out <- gc_ds(out, value = FALSE)
#' 
#' out <- gc_ds(out, value = TRUE)
#' 
#' out <- lapply(1:3, function(rep) {
#'   out <- mrgsim_ds(mod, data) 
#'   out
#' })
#' 
#' out <- gc_ds(out, value = FALSE)
#' 
#' @return 
#' An mrgsimsds object or a list of those objects is returned, potentially
#' with the `gc` status updated. 
#' 
#' @export
gc_ds <- function(x, ...) UseMethod("gc_ds")
#' @rdname gc_ds
#' @export
gc_ds.mrgsimsds <- function(x, value = NULL, notify = NULL, ...) {
  if(is.logical(value) && length(value)) {
    x$gc <- value[[1]]  
  }
  if(is.logical(notify) && length(notify)) {
    x$gc_notify <- notify[[1]]  
  }
  invisible(x)
}
#' @rdname gc_ds
#' @export
gc_ds.list <- function(x, value = NULL, notify = NULL, ...) {
  x <- lapply(x, gc_ds, value = value, notify = notify, ...)
  invisible(x)
}
