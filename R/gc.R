#' Set garbage collection behavior for mrgsimsds objects
#'
#' @description
#' Controls whether the underlying parquet files are automatically deleted
#' when the object is garbage collected (`value`) and whether a message is
#' issued when that deletion occurs (`notify`). Set `value = FALSE` to protect
#' files from cleanup; set back to `TRUE` to re-enable automatic deletion.
#' The `notify` flag is intended for debugging only; the `mrgsim.ds.show.gc`
#' option provides the same behavior package-wide.
#'
#' @param x an mrgsimsds object or a list of objects.
#' @param value logical; if `TRUE` the underlying files will be deleted on
#'   garbage collection.
#' @param notify logical; if `TRUE` a message will be issued when files are
#'   deleted on garbage collection. For debugging only; see also the
#'   `mrgsim.ds.show.gc` option.
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
#' When `x` is an mrgsimsds object, it is returned invisibly with `gc` and/or
#' `gc_notify` updated.
#'
#' When `x` is a list, it is returned invisibly with `gc_ds()` applied to
#' every mrgsimsds element; non-mrgsimsds elements are left unchanged.
#' 
#' @export
gc_ds <- function(x, ..., value = NULL, notify = NULL) UseMethod("gc_ds")
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
  cl <- simlist_classes(x)
  x[cl] <- lapply(x[cl], gc_ds, value = value, notify = notify, ...)
  invisible(x)
}
