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
#' after the model is loaded. See **Details**.
#'
#' @details
#' For most applications, the default output directory (`tempdir()`) is fine.
#' The main reason to set `ds_dir` to something else is when simulating on
#' worker nodes on a grid (e.g., Slurm or SGE). There, each worker has its own
#' `tempdir()`, which is usually on storage local to the node and is removed
#' when the worker's R session ends. In that case, set `ds_dir` (or the
#' `mrgsim.ds.dir` option) to a location on a shared file system so the output
#' is still available to the main R session after the workers finish.
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
