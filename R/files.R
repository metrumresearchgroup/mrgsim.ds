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

#' Move, rename, or write out data set files 
#' 
#' Use `move_ds()` to change the enclosing directory. `write_ds()` can also
#' move the files, but it always condenses th simulation output into a single 
#' parquet file if multiple files are backing the mrgsimsds object. All 
#' operations are made on the object in place; see **Details**. 
#' 
#' @param x an mrgsimsds object. 
#' @param path the new directory location for backing files.
#' @param id a short name used to create data set files for the simulated 
#' output.
#' @param sink the complete path (including file name) for a single parquet
#' file containing all simulated data; passed to [arrow::write_parquet()].
#' @param ... passed to [arrow::write_parquet()]; files are always written 
#' in parquet format.
#' 
#' @details
#' There is an important distinction between `write_ds()` and `move_ds()` or 
#' `rename_ds()` for multi-file objects. The backing files can be moved or 
#' written easily, without much computational effort. For multi-file simulation
#' outputs, `write_ds()` will need to read each file and then write the data 
#' out to a single file. Apache Arrow can do this very efficiently, but there 
#' will still be an additional, potentially noticeable computational effort  
#' 
#' When dataset files are rewritten to a single file with `write_ds()`, those 
#' files will no longer be cleaned up when the containing R object is finalized 
#' upon garbage collection. When dataset files are moved outside of `tempdir()`, 
#' those files, too, will no longer be cleaned up on garbage collection; but
#' file cleanup will continue to occur as long as the files remain under 
#' `tempdir()`. No change in finalization behavior due to garbage collection 
#' of the containing object will happen when files are renamed. 
#' 
#' The object (`x`) is required to own the underlying files in order to move
#' them with `move_ds()`; ownership is not required for `write_ds()`.
#' 
#' All three functions modify `x` in place and file ownership stays with `x`. 
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
#' rename_ds(out, id = "example-sims")
#' 
#' basename(out$files)
#' 
#' write_ds(out, sink = file.path(tempdir(), "example.parquet"))
#' 
#' basename(out$files)
#' 
#' \dontrun{
#'   move_ds(out, path = "data/simulated") 
#' }
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
  if(!grepl(basename(tempdir()), path)) {
    x$gc <- FALSE  
  }
  x <- refresh_ds(x)
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
  i <- seq_along(files)
  width <- floor(log10(length(i)))+1
  width <- max(width, 4)
  i <- formatC(i, width = width, flag = "0")
  id <- paste0(id, "-", i)
  new_names <- file_ds(id = id)
  x$files <- file_move(files, file.path(dirname(files), new_names))
  x <- refresh_ds(x)
  take_ownership(x)
  invisible(x)
}

#' @rdname move_ds
#' @export
write_ds <- function(x, sink, ...) {
  require_ds(x)
  owner <- check_ownership(x)
  if(owner) {
    disown(x)
    mv_or_cp <- file_move  
  } else {
    mv_or_cp <- file_copy
  }
  if(length(x$files)==1) {
    mv_or_cp(x$files, sink)
  } else {
    write_parquet(x$ds, sink, ...)
    if(owner) unlink(x$ds$files, recursive = TRUE)
  }
  x$gc <- FALSE
  x$files <- sink
  x <- refresh_ds(x)
  take_ownership(x)
  invisible(x)
}
