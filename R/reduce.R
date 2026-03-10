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
#' @param x a list of mrgsimsds objects or a single mrgsimsds object.
#' @param ... not used.
#' 
#' @details
#' When `x` is a list, a new object is created and returned. This new object
#' will take ownership for all the files from the objects in the list. 
#' 
#' When `x` is an mrgsimsds object, it will be returned invisibly with no 
#' modification.
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
#' A single mrgsimsds object. For the list method, the returned object
#' will own all underlying files.
#' 
#' @export
reduce_ds <- function(x, ...) UseMethod("reduce_ds")
#' @export
reduce_ds.mrgsimsds <- function(x, ...) {
  check_files_fatal(x)
  x <- safe_ds(x)
  x$pid <- Sys.getpid()
  invisible(x)
}

#' @export
reduce_ds.list <- function(x, ...) {
  simlist_reduce_ok(x)
  vapply(x, check_files_fatal, FALSE)
  files <- simlist_files(x)
  ans <- copy_ds(x[[1]], own = TRUE)
  run_gc <- isTRUE(ans$gc)
  disown(ans)
  sapply(x, disown)
  rm(x)
  ans$files <- files
  ans$ds <- open_dataset(sources = ans$files)
  ans$files <- ans$ds$files
  ans$dim <- dim(ans$ds)
  ans$pid <- Sys.getpid()
  if(run_gc) set_finalizer_ds(ans)
  class(ans) <- c("mrgsimsds", "environment")
  take_ownership(ans)
  ans
}
