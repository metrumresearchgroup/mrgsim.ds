total_size <- function(files) {
  size <- vapply(files, FUN = file.size, FUN.VALUE = 1.0)
  size <- sum(size, na.rm = TRUE)
  class(size) <- "object_size"
  size <- format(size, units = "auto")
  size
}

check_files_fatal <- function(x) {
  ans <- all(file.exists(x$files))
  if(!ans) {
    nfile <- length(x$files)
    owner <- ifelse(check_ownership(x), "yes", "no")
    model <- x$mod@model
    body <- c(
      "Model: {model}",
      "Files: {nfile}", 
      "Owner: {owner}" 
    )
    for(i in seq_along(body)) {
      body[i] <- glue(body[i])  
    }
    names(body) <- rep("*", length(body))
    abort(
      body = body,
      message = "[fatal] data set files do not exist.", 
      call = caller_env()
    )
  }
  return(invisible(TRUE))
}

file_ds <- function(id = NULL) {
  ext <- ".parquet"
  if(is.atomic(id)) {
    id <- as.character(id)
    file <- paste0(.global$file.prefix, id, ext)
  } else {
    file <- basename(tempfile(pattern = .global$file.prefix, fileext = ext))    
  }
  return(file)
}

file_numbers <- function(x) {
  n <- length(x)
  width <- floor(log10(n))+1
  part <- formatC(seq_along(x), width = width, flag = "0")
  paste0(part, "-", n)
}

#' Get the current location of mrgsimsds object files
#' 
#' @param x an mrgsimsds object.
current_location <- function(x) {
  require_ds(x)
  dirname(x$files[[1]])
}


#' Save and restore an mrgsimsds object
#'
#' @description
#' `save_ds()` serializes an mrgsimsds object to an `.rds` file, moving the
#' backing parquet files to the same directory as `file` (unless
#' `stay_put = TRUE`). Parquet filenames are stored as bare basenames inside
#' the `.rds`, so the `.rds` file and its parquet files must stay in the same
#' directory to be portable. **Do not restore the file with `readRDS()`**;
#' use `read_ds()` instead.
#'
#' `read_ds()` deserializes a file written by `save_ds()`, rebuilds the Arrow
#' Dataset pointer, and transfers full ownership of the backing files to the
#' returned object.
#'
#' @param x an mrgsimsds object.
#' @param file for `save_ds()`, the path to the output `.rds` file; the
#' directory component determines where backing parquet files are moved.
#' For `read_ds()`, the path to an `.rds` file written by `save_ds()`.
#' @param stay_put if `TRUE`, parquet files are left in their current directory
#' and the `.rds` is written there rather than at the directory implied by
#' `file`. A warning is issued when the files remain inside `tempdir()`.
#'
#' @return
#' `save_ds()` returns the path to the written `.rds` file, invisibly.
#'
#' `read_ds()` returns the restored mrgsimsds object invisibly. gc is disabled
#' (`gc = FALSE`) on the returned object and the caller holds ownership of the
#' backing files.
#'
#' @examples
#' mod <- house_ds()
#' 
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#'
#' file <- save_ds(out, file.path(tempdir(), "out.rds"))
#'
#' out2 <- read_ds(file)
#'
#' @seealso [move_ds()], [gc_ds()]
#' @export
save_ds <- function(x, file, stay_put = FALSE) {
  path <- dirname(file)
  if(isTRUE(stay_put)) {
    path <- current_location(x)
  }
  move <- path != current_location(x)
  stem <- tools::file_path_sans_ext(file)
  if(move) {
    x <- move_ds(x, path)
  } 
  path <- current_location(x)
  if(grepl(basename(tempdir()), path)) {
    warn("object and files will be saved to tempdir().")
  }
  file <- file.path(path, basename(file))
  reclass <- class(x)
  x <- as.list(x)
  x$ds <- .global$nullptr
  x$files <- basename(x$files)
  x <- structure(list(x), class = "mrgsimsds_save_ds", reclass = reclass)
  saveRDS(object = x, file = file)
  invisible(file)
}

#' @rdname save_ds
#' @export
read_ds <- function(file) {
  if(!file.exists(file)) abort("`file` does not exist.")
  cwd <- getwd()
  on.exit(setwd(cwd), add = TRUE)
  path <- dirname(file)
  file <- basename(file)
  setwd(path)
  x <- readRDS(file)
  if(!inherits(x, "mrgsimsds_save_ds")) {
    abort("[read_ds] unrecognized object in rds file.")
  }
  reclass <- attr(x, "reclass")
  x <- list2env(x[[1]])
  class(x) <- reclass
  if(!all(file.exists(x$files))) {
    abort("[read_ds] one or more files could not be located.")
  }
  x$files <- normalizePath(x$files, mustWork = TRUE)
  x <- refresh_ds(x)
  x <- copy_ds(x, own = TRUE)
  x <- gc_ds(x, value = FALSE)
  invisible(x)
}

#' Move, rename, combine files in mrgsimsds objects
#'
#' @description
#' Use `move_ds()` to change the enclosing directory. `rename_ds()`
#' keeps the files in place, but changes the file names. `combine_ds()`
#' brings simulated data from multiple backing file into a single file.
#'
#' ## Automatic gc adjustment
#'
#' Only `move_ds()` automatically updates the gc flag based on where the files
#' end up: files that remain under `tempdir()` keep `gc = TRUE`; files moved
#' outside `tempdir()` get `gc = FALSE`, protecting them from automatic
#' deletion. Neither `rename_ds()` nor `combine_ds()` changes the gc flag
#' because neither changes the file location.
#'
#' This automatic adjustment is skipped if the gc setting has been locked by a
#' prior call to [gc_ds()]. A warning is issued if gc is locked to `TRUE` but
#' files land outside `tempdir()`.
#'
#' The object (`x`) is required to own the underlying files in order to move,
#' rename, or combine them.
#'
#' All three functions modify `x` in place and file ownership stays with `x`.
#'
#' @param x an mrgsimsds object.
#' @param path the new directory location for backing files.
#' @param id a short name used to create data set files for the simulated
#' output.
#' 
#' @return
#' All three functions return `x` invisibly. The updated file list is
#' accessible via `x$files`.
#' 
#' @examples
#' 
#' mod <- house_ds()
#' 
#' out <- lapply(1:3, \(x) { mrgsim_ds(mod, events = ev(amt = 100)) })
#' 
#' out <- reduce_ds(out)
#' 
#' out <- rename(out, "new-name")
#' 
#' out$files
#' 
#' out <- combine_ds(out)
#' 
#' out$files
#' 
#' @export
move_ds <- function(x, path) {
  require_ds(x)
  if(!check_ownership(x)) {
    abort("cannot move files you don't own.")  
  }
  disown(x)
  files <- x$files
  if(!dir_exists(path)) {
    dir_create(path)  
  }
  x$files <- file_move(files, path)
  x <- refresh_ds(x)
  set_gc_auto(x)
  take_ownership(x)
  invisible(x)
}

#' @rdname move_ds
#' @export
rename_ds <- function(x, id) {
  require_ds(x)
  if(!check_ownership(x)) {
    abort("cannot rename files you don't own.")  
  }
  disown(x)
  files <- x$files
  parts <- file_numbers(files)
  id <- paste0(id, "-", parts)
  new_names <- file_ds(id = id)
  x$files <- file_move(files, file.path(dirname(files), new_names))
  x <- refresh_ds(x)
  take_ownership(x)
  invisible(x)
}

#' @rdname move_ds
#' @export
combine_ds <- function(x) {
  require_ds(x)
  if(!check_ownership(x)) {
    abort("cannot combine files you don't own.")  
  }
  if(length(x$files) > 1) {
    disown(x)
    path <- dirname(x$files[1])
    output <- file.path(path, file_ds())
    write_parquet(x$ds, output)
    unlink(x$files, recursive = TRUE)
    x$files <- output
    x <- hash_files(x)
  }
  x <- refresh_ds(x)
  take_ownership(x)
  invisible(x)
}
