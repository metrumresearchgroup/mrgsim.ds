#' Manage simulated outputs in the output directory
#'
#' @description
#' Functions for inspecting and cleaning up package-managed parquet files in
#' the output directory (`tempdir()` unless you set another location; see
#' [mread_ds()]). `list_temp()` shows what is present; `purge_temp()`
#' resets the simulation file system.
#'
#' `purge_temp()` deletes all package-managed files in `dir` unconditionally
#' and clears the ownership maps, resetting the system to a clean state. It is
#' intended for use in testing teardown or session cleanup, not routine usage.
#' Because files outside of `tempdir()` might be shared with other R processes
#' (e.g., when simulating in parallel), `force = TRUE` is required to purge
#' them.
#'
#' @param dir the directory to list or purge; defaults to
#' `getOption("mrgsim.ds.dir")`, falling back to `tempdir()`. Note that this is
#' the session default and not necessarily where any specific object wrote its
#' files; see [files_ds()].
#' @param quietly if `TRUE`, suppresses console output (the file listing for
#' `list_temp()` and the deletion summary for `purge_temp()`).
#' @param force if `TRUE`, allow `purge_temp()` to delete files in a directory
#' which is not under `tempdir()`.
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
list_temp <- function(dir = default_dir_ds(), quietly = FALSE) {
  temp <- list_files_ds(dir)
  if(isTRUE(quietly)) {
    return(invisible(temp))
  }
  if(!length(temp)) {
    cat("No files in ", dir, ".\n", sep = "")
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
purge_temp <- function(dir = default_dir_ds(), quietly = FALSE, 
                       force = FALSE) {
  if(!isTRUE(force) && dir_exists(dir) && !in_tempdir(dir)) {
    abort(
      c(
        "refusing to purge files in a directory outside of `tempdir()`.",
        i = glue("pass `force = TRUE` to purge {dir}.")
      )
    )
  }
  temp <- list_files_ds(dir)
  unlink(x = temp, recursive = TRUE)
  clear_ownership()
  if(!isTRUE(quietly)) {
    message("Discarding ", length(temp), " files.")
  }
  return(invisible(NULL))
}

list_files_ds <- function(dir) {
  list.files(dir, pattern = .global$file.re, full.names = TRUE)
}
