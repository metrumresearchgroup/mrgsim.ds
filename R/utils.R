#' Check if object inherits mrgsimsds
#'
#' @param x object to check.
#'
#' @return
#' `TRUE` if `x` inherits from `mrgsimsds`; `FALSE` otherwise.
#'
#' @examples
#' mod <- house_ds()
#'
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#'
#' is_mrgsimsds(out)
#'
#' is_mrgsimsds(list())
#'
#' @export
is_mrgsimsds <- function(x) {
  inherits(x, "mrgsimsds")  
}

require_ds <- function(x) {
  if(!inherits(x, "mrgsimsds")) {
    actual <- class(x)
    if(length(actual) > 1) {
      actual <- paste0(actual, collapse = "/")  
    }
    msg <- "an 'mrgsimsds' object is required, not '{actual}'."
    abort(glue(msg))
  }
}

# Formatter from the scales package
format_big <- function() {
  scales::label_number(
    accuracy = 0.1, 
    scale_cut = scales::cut_short_scale()
  )
}
#' Save information about the R process that loaded a model
#'
#' Stamps the model object with the current process ID and `tempdir()` path so
#' that [mrgsim_ds()] knows where to write output files. This is called
#' automatically by [mread_ds()], [house_ds()], and the other model-loading
#' wrappers. Call it directly only when you load a model through the base
#' mrgsolve functions (e.g. [mrgsolve::mread()]) and still want to use
#' [mrgsim_ds()].
#'
#' @param x a model object.
#' 
#' @return 
#' An updated model object suitable for using with [mrgsim_ds()].
#' 
#' @examples
#' mod <- mrgsolve::house()
#' 
#' mod <- save_process_info(mod)
#' 
#' @export
save_process_info <- function(x) {
  if(!is.mrgmod(x)) { # nocov start
    abort("`x` must be an mrgmod object.")  
  } # nocov end
  x@envir$mrgsim.ds.mread_valid <- TRUE
  x@envir$mrgsim.ds.mread_pid <- Sys.getpid()
  x@envir$mrgsim.ds.mread_tempdir <- tempdir()
  x
}

invalid_ds <- function(x) {
  identical(x$ds$pointer(), .global$nullptr)  
}

safe_ds <- function(x) {
  if(invalid_ds(x)) x <- refresh_ds(x)
  invisible(x)
}

pid_changed <- function(x) {
  if(is.mrgmod(x)) {
    return(Sys.getpid() != get_mread_pid(x))
  }
  if(is_mrgsimsds(x)) {
    return(Sys.getpid() != x$pid)  
  }
  abort("cannot assess pid on this object.")
}

get_mread_pid <- function(x) {
  stopifnot("this function was expecting a model object." = is.mrgmod(x))
  pid <- x@envir$mrgsim.ds.mread_pid
  if(!is.numeric(pid)) {
    pid <- -1e9
  }
  pid
}

get_mread_tempdir <- function(x) {
  tempd <- x@envir$mrgsim.ds.mread_tempdir
  tempd
}

mread_with_ds <- function(x) {
  is.character(x@envir$mrgsim.ds.mread_tempdir)  
}

get_nid_from_ds <- function(x, nid = 10, batch_size = 10000) {
  x <- safe_ds(x)
  ds <- x$ds
  scanner <- Scanner$create(ds, batch_size = batch_size)
  reader <- scanner$ToRecordBatchReader()
  count_id <- 1
  iter <- 0
  simsl <- vector(mode = "list", length = nid)
  while(count_id < (nid+2)) {
    batch <- as.data.frame(reader$read_next_batch())
    if(nrow(batch)==0) {
      count_id <- nid + 2
      break;  
    }
    iter <- iter + 1
    ids <- unique(batch$ID)
    count_id <- count_id + length(ids)
    simsl[[iter]] <- batch
  }
  simsl <- simsl[seq(iter)]
  sims <- bind_rows(simsl)
  uid <- unique(sims$ID)
  uid <- uid[seq(nid)]
  sims <- sims[sims$ID %in% uid,]  
  sims
}

set_finalizer_ds <- function(x) {
  reg.finalizer(x, clean_up_ds, onexit = TRUE)
  x
}
