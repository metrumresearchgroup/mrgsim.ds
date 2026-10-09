#' Override the directory under which `mrgsim.ds` creates its temporary directory
#'
#' @description
#'
#' By default, `mrgsim.ds` stores its files under a dedicated temporary
#' directory within [tempdir()]. Use `set_tempdir_base()` to specify an
#' alternative location to [tempdir()].
#'
#' This is useful in scenarios where the work will be spread across machines
#' (e.g., via Slurm) that do not share access to the file system on which
#' [tempdir()] resides.
#'
#' @details
#'
#' Although the specified directory may reside anywhere, it should be treated as
#' a temporary directory. Use [save_ds()] or [move_ds()] to move the files to
#' more permanent locations.
#'
#' `mrgsim.ds` may delete the backing parquet files in its temporary directory
#' (see [gc_ds()]), but it does not delete `path` or the temporary directory
#' that it creates within it. The caller is expected to manage this temporary
#' directory, including its removal.
#'
#' This function aborts if it is called after any `mrgsim.ds` functionality that
#' relies of the temporary directory.
#'
#' @param path The name of an existing directory.
#'
#' @return The absolute path (invisibly) to the subdirectory under `path` that
#'   `mrgsim.ds` will use as its temporary directory.
#'
#' @seealso [list_temp()]
#' @export
set_tempdir_base <- function(path) {
  if (!is.null(.global[["tempdir"]])) {
    abort(
      c(
        "A temporary directory is already in use.",
        "i" = "Call `set_tempdir_base()` before any other mrgsim.ds functions."
      )
    )
  }

  if (!fs::dir_exists(path)) {
    abort(paste("`path` is not an existing directory:", path))
  }

  .global[["tempdir_base"]] <- normalizePath(path, mustWork = TRUE)

  return(invisible(our_tempdir()))
}

our_tempdir <- function() {
  tdir <- .global[["tempdir"]]
  if (!is.null(tdir)) {
    return(tdir)
  }

  basedir <- .global[["tempdir_base"]]
  if (is.null(basedir)) {
    basedir <- tempdir()
  }

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

  # Even if the user called set_tempdir_base with a path outside of tempdir(),
  # continue to consider tempdir() here so that, e.g., a warning is given if
  # save_ds writes the file under tempdir().
  fs::path_has_parent(path, tdir) || fs::path_has_parent(path, our_tempdir())
}

#' Manage simulated outputs in the per-session temporary directory
#'
#' @description
#' Functions for inspecting and cleaning up package-managed parquet files in
#' the temporary directory. `list_temp()` shows what is present; `purge_temp()`
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
#' @seealso [set_tempdir_base()]
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
