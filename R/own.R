hash2addr <- new.env(parent = emptyenv(), hash = TRUE, size = 5000L)
hash2file <- new.env(parent = emptyenv(), hash = TRUE, size = 5000L)

digest_algo <- "xxh3_64"

clear_ownership <- function() {
  rm(list = names(hash2addr), envir = hash2addr)
  rm(list = names(hash2file), envir = hash2file)
}

teardown_ds <- function() {
  gc()
  purge_temp(quietly = TRUE)
  clear_ownership()
  unlink(list.files(.global$trashcan, full.names = TRUE))
}

# This code needs to check pid_changed on the model object, 
# not the mrgsimsds object.
clean_up_ds <- function(x) {
  if(x$gc && check_ownership(x) && !pid_changed(x$mod)) {
    if(isTRUE(x$gc_notify)) {
      n <- length(x$files)
      msg <- paste0("[mrgsim.ds] cleaning up ", n, " file(s) ...")
      message(msg)
    }
    send_to_trash(x)
    unlink(x$files, recursive = TRUE)
  }
}

hash_files <- function(x) {
  h <- getVDigest(algo = digest_algo)
  x$hash <- h(x$files)
  x
}

# You can take ownership if no one owns the file
# or the object owns the file. Partial ownership (some files owned by another
# object, some not) is not allowed — return FALSE to be conservative.
can_take_ownership <- function(x) {
  owned <- x$hash %in% names(hash2addr)
  if(!any(owned)) {
    return(!owned)
  }
  if(all(owned)) {
    return(check_ownership(x))
  }
  return(FALSE)
}

#' Ownership of simulation files
#'
#' @description
#' Functions to check ownership or disown simulation output files on disk.
#'
#' One situation where you need to take over ownership is when you are
#' simulating in parallel, and the simulation happens in another R process.
#' `mrgsim.ds` ownership is established when the simulation returns and the
#' `mrgsimsds` object is created. When this happens in another R process (e.g.,
#' on a worker node), there is no way to transfer that information back to the
#' parent process. In that case, a call to `take_ownership()` once the results
#' are returned to the parent process would be appropriate. Typically, these
#' results are returned as a list and a call to [reduce_ds()] will create a
#' single object pointing to and owning multiple files. Therefore, it should be
#' rare to call `take_ownership()` directly; if doing so, please make sure you
#' understand what is going on.
#'
#' @param x an mrgsimsds object.
#' @param full.names if `TRUE`, include the directory path when listing file
#' ownership.
#' 
#' @return 
#' - `check_ownership`: `TRUE` if `x` owns the underlying files; `FALSE` 
#'   otherwise.
#' - `list_ownership`: a data.frame of ownership information.
#' - `ownership`: nothing; used for side effects.
#' - `disown`: `x` is returned invisibly; it is not modified.
#' - `take_ownership`: `x` is returned invisibly after its hash and the
#'   package-level ownership maps are updated in place.
#' @examples
#' mod <- house_ds()
#' 
#' out <- mrgsim_ds(mod, id = 1)
#' 
#' check_ownership(out)
#' 
#' ownership()
#' 
#' list_ownership()
#' 
#' e1 <- ev(amt = 100)
#' e2 <- ev(amt = 200)
#' 
#' out <- list(mrgsim_ds(mod, e1), mrgsim_ds(mod, e2))
#' 
#' sims <- reduce_ds(out)
#' 
#' ownership()
#' 
#' check_ownership(sims)
#' 
#' check_ownership(out[[1]])
#' 
#' check_ownership(out[[2]])
#' 
#' 
#' @seealso [reduce_ds()], [copy_ds()].
#' 
#' @rdname ownership
#' @name ownership
#' @export
ownership <- function() {
  clean_up_trash()
  addrs <- mget(names(hash2addr), envir = hash2addr)
  if(!length(addrs)) {
    message("No ownership information yet.")
    return(invisible(NULL))
  }
  files <- mget(names(hash2file), envir = hash2file)
  size <- total_size(files)
  nfile <- length(unique(files))
  nadd <- length(unique(addrs))
  msg <- "> Objects: {nadd} | Files: {nfile} | Size: {size}"
  cat(glue(msg), sep = "")
  return(invisible(NULL))
}

#' @rdname ownership
#' @export
list_ownership <- function(full.names = FALSE) {
  clean_up_trash()
  addrs <- unname(mget(names(hash2addr), envir = hash2addr))
  if(!length(addrs)) {
    ans <- data.frame(file = character(0), address = character(0))
    return(ans)
  }
  files <- unname(mget(names(hash2file), envir = hash2file))
  ans <- data.frame(
    file = unlist(files), 
    address = unlist(addrs), 
    stringsAsFactors = FALSE
  )
  if(isFALSE(full.names)) {
    ans$file <- basename(ans$file)
  }
  rownames(ans) <- NULL
  ans
}

#' @rdname ownership
#' @export
check_ownership <- function(x) {
  require_ds(x)
  clean_up_trash()
  keys <- x$hash[x$hash %in% names(hash2addr)]
  if(length(keys) != length(x$hash)) {
    return(FALSE)  
  }
  addrs <- mget(keys, envir = hash2addr)
  return(all(addrs==x$address))
}

#' @rdname ownership
#' @export
disown <- function(x) {
  require_ds(x)
  if(is.null(x$hash)) abort("files are not hashed.")
  to_rm <- x$hash[x$hash %in% names(hash2addr)]
  rm(list = to_rm, envir = hash2addr)
  to_rm <- x$hash[x$hash %in% names(hash2file)]
  rm(list = to_rm, envir = hash2file)
  invisible(x)
}

#' @rdname ownership
#' @export
take_ownership <- function(x) {
  require_ds(x)
  clean_up_trash()
  x <- hash_files(x)

  if(!length(x$files) == length(x$hash)) {
    abort("length mismatch between files and hash.")  
  }
  
  l1 <- as.list(rep(x$address, length(x$hash)))
  names(l1) <- x$hash
  list2env(l1, envir = hash2addr)
  
  l2 <- as.list(x$files)
  names(l2) <- x$hash
  list2env(l2, envir = hash2file)
  
  return(invisible(x))
}

# For testing only
transfer_ownership <- function(x, address) {
  l <- as.list(rep(address, length(x$files)))
  names(l) <- x$hash
  list2env(l, envir = hash2addr)
}

send_to_trash <- function(x) {
  for(i in seq_along(x$hash)) {
    writeLines(
      con = file.path(.global$trashcan, x$hash[i]), 
      text = x$files[i]
    )
  }
}

clean_up_trash <- function() {
  f <- list.files(.global$trashcan, full.names = TRUE)
  if(!length(f)) return(NULL)
  trashed <- sapply(f, readLines)
  f <- f[!file.exists(trashed)]
  if(!length(f)) return(NULL)
  hash <- basename(f)
  to_rm <- hash[hash %in% names(hash2addr)]
  if(length(to_rm)) {
    rm(list = to_rm, envir = hash2addr)
  }
  to_rm <- hash[hash %in% names(hash2file)]
  if(length(to_rm)) {
    rm(list = to_rm, envir = hash2file)
  }
  unlink(f, recursive = TRUE)
  return(NULL)
}

#' Copy an mrgsimsds object
#'
#' @description
#' Creates a new mrgsimsds object pointing to the same parquet files as `x`.
#' By default the new object takes ownership of those files, which means the
#' original object loses ownership and its files will not be deleted when it
#' is garbage collected.
#'
#' @param x an mrgsimsds object to copy.
#' @param own logical; if `TRUE` the new object takes ownership of the files;
#' if `FALSE` ownership is left unchanged.
#'
#' @return
#' A new mrgsimsds object with the same files and fields as `x`, a fresh
#' memory address, and `pid` set to the current process.
#' 
#' @examples
#' mod <- house_ds()
#' 
#' out <- mrgsim_ds(mod)
#' 
#' out2 <- copy_ds(out)
#' 
#' check_ownership(out)
#' 
#' check_ownership(out2)
#' 
#' @export
copy_ds <- function(x, own = TRUE) {
  require_ds(x)
  ls_in <- ls(x)
  ans <- new.env(parent = emptyenv())
  ans$ds <- open_dataset(x$files)
  ans$files <- x$files
  ans$mod <- x$mod
  ans$dim <- x$dim
  ans$head <- x$head
  ans$names <- x$names
  ans$variables <- x$variables
  ans$pid <- Sys.getpid()
  ans$gc <- x$gc
  ans$gc_locked <- x$gc_locked
  ans$gc_notify <- x$gc_notify
  ans$address <- obj_addr(ans)
  set_finalizer_ds(ans)
  class(ans) <- c("mrgsimsds", "environment")
  if(own) {
    take_ownership(ans)
  } else {
    hash_files(ans)
  }
  ls_out <- ls(ans)
  stopifnot("bad copy" = identical(ls_in, ls_out))
  ans
}
