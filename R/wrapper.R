#' Load an mrgsolve model for Arrow-backed simulation
#'
#' @description
#' Thin wrappers around mrgsolve model-loading functions (`mread()`,
#' `mcode()`, `modlib()`, `house()`, `mread_cache()`) that additionally call
#' [save_process_info()] to stamp the model with the current process ID and the
#' directory where simulated output should be written. This stamp is required by
#' [mrgsim_ds()] to correctly associate simulation outputs with the process that
#' created them.
#'
#' @param ... passed to the corresponding mrgsolve function.
#' @param ds_dir the directory where simulated output should be written; when
#' `NULL`, `getOption("mrgsim.ds.dir")` is used, falling back to `tempdir()`.
#' The directory is created when it doesn't exist and the location is resolved
#' one time, here, when the model is loaded. See [set_ds_dir()] to change this
#' after the model is loaded.
#'
#' @seealso [save_process_info()], [set_ds_dir()], [get_ds_dir()].
#'
#' @return
#' A model object with process information saved, suitable for use with
#' [mrgsim_ds()].
#'
#' @examples
#' mod <- house_ds()
#'
#' mod
#'
#' mod <- house_ds(ds_dir = file.path(tempdir(), "sims"))
#'
#' get_ds_dir(mod)
#'
#' @export
mread_ds <- function(..., ds_dir = NULL) {
  x <- mread(...)
  save_process_info(x, ds_dir = ds_dir)
}

#' @rdname mread_ds
#' @export
mcode_ds <- function(..., ds_dir = NULL) {
  x <- mcode(...)
  save_process_info(x, ds_dir = ds_dir)
}

#' @rdname mread_ds
#' @export
modlib_ds <- function(..., ds_dir = NULL) {
  x <- modlib(...)
  save_process_info(x, ds_dir = ds_dir)
}

#' @rdname mread_ds
#' @export
house_ds <- function(..., ds_dir = NULL) {
  x <- house(...)
  save_process_info(x, ds_dir = ds_dir)
}

#' @rdname mread_ds
#' @export
mread_cache_ds <- function(..., ds_dir = NULL) {
  x <- mread_cache(...)
  save_process_info(x, ds_dir = ds_dir)
}
