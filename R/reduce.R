simlist_reduce_ok <- function(x) {
  classes <- simlist_classes(x)
  if(!all(classes)) {
    abort(
      "all objects in list must inherit from `mrgsimsds`.",
      call = caller_env()
    )
  }
  models <- simlist_models(x)
  if(!all(models)) {
    abort(
      message = "all objects in list must be derived from the same model.",
      call = caller_env()
    )
  }
  cols <- simlist_cols(x)
  if(!all(cols)) {
    abort(
      message = "all objects in list must have the same column names.",
      call = caller_env()
    )
  }
  files <- simlist_files(x)
  if(length(files) != length(unique(files))) {
    abort(
      message = "objects in list must have unique file names.",
      call = caller_env()
    )
  }
  if(!all(file.exists(files))) {
    n <- length(files)
    ne <- sum(!file.exists(files))
    msg <- glue("{ne} of {n} parquet files do not exist.")
    abort(
      message = msg, 
      call = caller_env()
    )
  }
  can_own <- simlist_can_own(x)
  if(!all(can_own)) {
    abort(
      message = "another object cannot own files in an object getting reduced.", 
      call = caller_env()
    )
  }
}


#' Reduce a list of mrgsimsds objects into a single object
#'
#' Combines a list of mrgsimsds objects — typically the replicate outputs from
#' a parallel simulation — into one object backed by all of their parquet files.
#' Ownership of every file is transferred to the new object.
#'
#' @param x a list of mrgsimsds objects or a single mrgsimsds object.
#' @param ... not used.
#' 
#' @examples
#' mod <- modlib_ds("popex", outvars = "IPRED")
#' 
#' data <- ev_expand(amt = 100, ID = 1:10)
#' 
#' out <- lapply(1:3, function(rep) {
#'   out <- mrgsim_ds(mod, data) 
#'   out
#' })
#' 
#' length(out)
#' 
#' sims <- reduce_ds(out)
#' 
#' sims
#' 
#' check_ownership(sims)
#' 
#' lapply(out, check_ownership)
#' 
#' @return
#' When `x` is a list, a new mrgsimsds object is returned that owns all
#' underlying parquet files; the input objects are disowned.
#'
#' When `x` is an mrgsimsds object, it is validated, refreshed, and returned
#' invisibly with its `pid` updated to the current process.
#'
#' @export
reduce_ds <- function(x, ...) UseMethod("reduce_ds")
#' @rdname reduce_ds
#' @export
reduce_ds.mrgsimsds <- function(x, ...) {
  check_files_fatal(x)
  x <- safe_ds(x)
  x$pid <- Sys.getpid()
  invisible(x)
}

#' @rdname reduce_ds
#' @export
reduce_ds.list <- function(x, ...) {
  simlist_reduce_ok(x)
  files <- simlist_files(x)
  ans <- copy_ds(x[[1]], own = FALSE)
  sapply(x, disown)
  rm(x)
  ans$ds <- open_dataset(sources = files)
  ans$files <- ans$ds$files
  ans$dim <- dim(ans$ds)
  take_ownership(ans)
  ans
}
