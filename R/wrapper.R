#' Load an mrgsolve model for Arrow-backed simulation
#'
#' @description
#' Thin wrappers around mrgsolve model-loading functions (`mread()`,
#' `mcode()`, `modlib()`, `house()`, `mread_cache()`) that additionally call
#' [save_process_info()] to stamp the model with the current process ID. This
#' stamp is required by [mrgsim_ds()] to correctly associate simulation outputs
#' with the process that created them.
#'
#' @param ... passed to the corresponding mrgsolve function.
#'
#' @seealso [save_process_info()].
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
#' @export
mread_ds <- function(...) {
  x <- mread(...)
  save_process_info(x)
}

#' @rdname mread_ds
#' @export
mcode_ds <- function(...) {
  x <- mcode(...)
  save_process_info(x)
}

#' @rdname mread_ds
#' @export
modlib_ds <- function(...) {
  x <- modlib(...)
  save_process_info(x)
}

#' @rdname mread_ds
#' @export
house_ds <- function(...) {
  x <- house(...)
  save_process_info(x)
}

#' @rdname mread_ds
#' @export
mread_cache_ds <- function(...) {
  x <- mread_cache(...)
  save_process_info(x)
}
