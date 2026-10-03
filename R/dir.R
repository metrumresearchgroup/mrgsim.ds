#' Set or get the output directory on a model object
#'
#' @description
#' Simulated output is written to a directory which is resolved one time, when
#' the model is loaded (see [mread_ds()]), and stamped on the model object. Use
#' `set_ds_dir()` to re-target a model after it was loaded and `get_ds_dir()`
#' to see where simulated output will be written.
#'
#' The output directory is resolved in this order:
#'
#' 1. the `ds_dir` argument to [mread_ds()] and friends
#' 2. `getOption("mrgsim.ds.dir")`
#' 3. `tempdir()`
#'
#' Setting the `mrgsim.ds.dir` option before loading a model is the most
#' convenient way to send output to a location which every worker can reach
#' when simulating in parallel; `tempdir()` on a worker node is generally
#' _not_ the same directory as `tempdir()` on the parent node.
#'
#' The directory is created when it doesn't exist. Note that output files are
#' subject to garbage collection in the output directory whether or not that
#' directory is under `tempdir()`; see [move_ds()] and [gc_ds()].
#'
#' Like other updates to the model environment, `set_ds_dir()` works by
#' reference: copies of a model object share one environment, so they will all
#' write to the directory you set. Load the model a second time (see
#' [mread_ds()]) when you want two model objects writing to two different
#' directories.
#'
#' @param mod a model object loaded with [mread_ds()] or equivalent.
#' @param dir the directory where simulated output should be written.
#'
#' @return
#' `set_ds_dir()` returns the updated model object.
#'
#' `get_ds_dir()` returns the output directory as a string.
#'
#' @examples
#' mod <- house_ds()
#'
#' get_ds_dir(mod)
#'
#' mod <- set_ds_dir(mod, file.path(tempdir(), "sims"))
#'
#' get_ds_dir(mod)
#'
#' @seealso [mread_ds()], [save_process_info()], [move_ds()], [gc_ds()]
#'
#' @export
set_ds_dir <- function(mod, dir) {
  if(!is.mrgmod(mod)) {
    abort("`mod` must be an mrgmod object.")
  }
  if(!mread_with_ds(mod)) {
    abort("model was not loaded with `mread_ds()` or equivalent.")
  }
  # Only the directory gets re-stamped here; the process information is left
  # alone so that gc behavior continues to track the parent R process
  mod@envir$mrgsim.ds.output_dir <- check_ds_dir(dir)
  mod
}

#' @rdname set_ds_dir
#' @export
get_ds_dir <- function(mod) {
  if(!is.mrgmod(mod)) {
    abort("`mod` must be an mrgmod object.")
  }
  get_output_dir(mod)
}

# The session-level default, used when `ds_dir` isn't passed when loading a model
default_dir_ds <- function() {
  dir <- getOption("mrgsim.ds.dir")
  if(is.null(dir)) {
    return(tempdir())
  }
  if(!is.character(dir) || length(dir) != 1L) {
    abort("the `mrgsim.ds.dir` option must be a single string.")
  }
  dir
}

# Validate and create an output directory; this is called whenever the
# directory is set so that bad input fails there rather than mid-simulation
check_ds_dir <- function(dir, create = TRUE, call = caller_env()) {
  if(!is.character(dir) || length(dir) != 1L || is.na(dir)) {
    abort("the output directory must be a single string.", call = call)
  }
  if(grepl(" ", dir)) {
    abort("the output directory cannot contain spaces.", call = call)
  }
  if(!dir_exists(dir)) {
    if(!isTRUE(create)) {
      abort(glue("the output directory does not exist: {dir}"), call = call)
    }
    dir_create(dir)
  }
  dir <- normalizePath(dir, mustWork = TRUE)
  if(file.access(dir, mode = 2) != 0) {
    abort(glue("the output directory is not writable: {dir}"), call = call)
  }
  dir
}

# Where output gets written for this model object
get_output_dir <- function(x) {
  dir <- x@envir$mrgsim.ds.output_dir
  if(!is.character(dir)) {
    # models stamped by mrgsim.ds < 0.2.0
    dir <- x@envir$mrgsim.ds.mread_tempdir
  }
  if(!is.character(dir)) {
    abort(
      c(
        "the model object does not have an output directory.",
        i = "re-load the model with `mread_ds()` or call `save_process_info()`."
      )
    )
  }
  dir
}
