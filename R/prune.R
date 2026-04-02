#' Prune a list of mrgsimsds objects
#'
#' @description
#' Filters a mixed list down to only the elements that are `mrgsimsds` objects,
#' dropping anything else (e.g. `NULL`, data frames, character vectors). When
#' passed a single `mrgsimsds` object it is returned invisibly unchanged.
#'
#' @param x a list of R objects or a single mrgsimsds object.
#' @param inform (list method only) issue a message when objects in some list
#'   slots are dropped.
#' @param ... not used.
#' 
#' @examples
#' mod <- house_ds(end = 24)
#' 
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#' 
#' sims <- list(out, letters)
#' 
#' prune_ds(sims)
#' 
#' @return
#' When `x` is a list, it will be returned with only the mrgsimsds objects
#' retained. If no mrgsimsds objects are found, an empty list is returned with
#' a warning.
#'
#' When `x` is an mrgsimsds object, it will be invisibly returned.
#' 
#' @export
prune_ds <- function(x, ..., inform = TRUE) UseMethod("prune_ds")
#' @rdname prune_ds
#' @export
prune_ds.mrgsimsds <- function(x, ...) {
  invisible(x)
}
#' @rdname prune_ds
#' @export
prune_ds.list <- function(x, ..., inform = TRUE) {
  cl <- simlist_classes(x)
  if(isTRUE(inform) && !all(cl)) {
    n <- sum(!cl)
    msg <- "dropping {n} objects that are not mrgsimsds."
    inform(glue(msg))     
  }
  if(!any(cl)) {
    warn("no mrgsimsds objects were found.")
  }
  x[cl]
}
