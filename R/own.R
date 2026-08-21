# Map from the file name to the address of the mrgsimsds object that "owns" it
addresses <- new.env(parent = emptyenv(), hash = TRUE, size = 5000L)

clear_ownership <- function() {
  rm(list = names(addresses), envir = addresses)
}

teardown_ds <- function() {
  purge_temp(quietly = TRUE)
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
    unlink(x$files, recursive = TRUE)
  }
}

# You can take ownership if no one owns the file
# or the object owns the file. Partial ownership (some files owned by another
# object, some not) is not allowed — return FALSE to be conservative.
can_take_ownership <- function(x) {
  owned <- x$files %in% names(addresses)
  if (!any(owned)) {
    return(TRUE)
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
  files <- names(addresses)
  addrs <- mget(files, envir = addresses)
  if(!length(addrs)) {
    message("No ownership information yet.")
    return(invisible(NULL))
  }
  size <- total_size(files)
  nfile <- length(unique(files))
  nadd <- length(unique(addrs))
  msg <- "> Objects: {nadd} | Files: {nfile} | Size: {size}"
  cat(glue(msg), "\n", sep = "")
  return(invisible(NULL))
}

#' @rdname ownership
#' @export
list_ownership <- function(full.names = FALSE) {
  files <- names(addresses)
  addrs <- unname(mget(files, envir = addresses))
  if(!length(addrs)) {
    ans <- data.frame(file = character(0), address = character(0))
    return(ans)
  }
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
  keys <- x$files[x$files %in% names(addresses)]
  if(length(keys) != length(x$files)) {
    return(FALSE)  
  }
  addrs <- mget(keys, envir = addresses)
  return(all(addrs==x$address))
}

#' @rdname ownership
#' @export
disown <- function(x) {
  require_ds(x)
  to_rm <- x$files[x$files %in% names(addresses)]
  rm(list = to_rm, envir = addresses)
  invisible(x)
}

#' @rdname ownership
#' @export
take_ownership <- function(x) {
  require_ds(x)

  l <- as.list(rep(x$address, length(x$files)))
  names(l) <- x$files
  list2env(l, envir = addresses)

  return(invisible(x))
}

# For testing only
transfer_ownership <- function(x, address) {
  l <- as.list(rep(address, length(x$files)))
  names(l) <- x$files
  list2env(l, envir = addresses)
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
  }
  ls_out <- ls(ans)
  stopifnot("bad copy" = identical(ls_in, ls_out))
  ans
}
