our_tempdir <- function() {
  tdir <- .global[["tempdir"]]
  if (!is.null(tdir)) {
    return(tdir)
  }

  basedir <- tempdir()

  tdir <- tempfile(pattern = "mrgsim.ds-", tmpdir = basedir)
  dir.create(tdir)
  tdir <- normalizePath(tdir, mustWork = TRUE)
  .global[["tempdir"]] <- tdir

  return(tdir)
}

in_tempdir <- function(files) {
  if (!length(files)) {
    abort(c("Must specify at least one file."))
  }

  if (length(unique(dirname(files))) > 1) {
    abort(c("All files must be in the same directory.", files))
  }

  tdir <- normalizePath(tempdir(), mustWork = TRUE)
  path <- normalizePath(files[1], mustWork = TRUE)

  return(fs::path_has_parent(path, tdir))
}

#' Manage simulated outputs in the per-session temporary directory
#'
#' @description
#' Functions for inspecting and cleaning up package-managed parquet files in
#' `tempdir()`. `list_temp()` shows what is present; `purge_temp()`
#' resets the simulation file system.
#'
#' `purge_temp()` deletes all package-managed files unconditionally and clears
#' the ownership maps, resetting the system to a clean state. It is intended
#' for use in testing teardown or session cleanup, not routine usage.
#'
#' @param quietly if `TRUE`, suppresses console output (the file listing for
#' `list_temp()` and the deletion summary for `purge_temp()`).
#'
#' @return
#' `list_temp()` returns a character vector of file paths invisibly, and prints
#' a summary to the console unless `quietly = TRUE`.
#'
#' `purge_temp()` returns `NULL` invisibly.
#'
#' @examples
#' mod <- house_ds()
#'
#' out <- lapply(1:10, \(x) mrgsim_ds(mod))
#'
#' list_temp()
#'
#' purge_temp()
#'
#' list_temp()
#'
#' @export
list_temp <- function(quietly = FALSE) {
  temp <- list.files(our_tempdir(), pattern = .global$file.re, full.names = TRUE)
  if(isTRUE(quietly)) {
    return(invisible(temp))
  }
  if(!length(temp)) {
    cat("No files in tempdir.\n")
    return(invisible(temp))
  }
  size <- total_size(temp)
  if(length(temp) < 6) {
    show <- paste0("- ", basename(temp))
  } else {
    show <- c(
      paste0("- ", basename(head(temp, n = 2))),
      "   ...",
      paste0("- ", basename(tail(temp, n = 2)))
    )
  }
  header <- paste0(length(temp), " files [", size, "]")
  cat(c(header, show), sep = "\n")
  return(invisible(temp))
}

#' @rdname list_temp
#' @export
purge_temp <- function(quietly = FALSE) {
  temp <- list.files(our_tempdir(), pattern = .global$file.re, full.names = TRUE)
  unlink(x = temp, recursive = TRUE)
  clear_ownership()
  if(!isTRUE(quietly)) {
    message("Discarding ", length(temp), " files.")
  }
  return(invisible(NULL))
}
