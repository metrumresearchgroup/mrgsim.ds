
#' Coerce an mrgsims object to 'Apache' 'Arrow'-backed mrgsimsds object
#' 
#' All simulation data is saved to `tempdir()` according to the parent or head
#' node that the computation is run from. See [move_ds()] to [write_ds()]
#' change the location of the files, protecting them from the garbage collector.
#' 
#' @inheritParams mrgsim_ds
#' @param x an mrgsims object. 
#' 
#' @details
#' This function will only take output from [mrgsolve::mrgsim()]. 
#' 
#' @examples
#' mod <- house_ds()
#' 
#' data <- ev_expand(amt = 100, ID = 1:10)
#' 
#' out <- mrgsolve::mrgsim(mod, data)
#' 
#' obj <- as_mrgsim_ds(out)
#' 
#' obj
#' 
#' @return
#' An object with class `mrgsimsds`.
#' 
#' @seealso [mrgsim_ds()].
#' 
#' @export
as_mrgsim_ds <- function(x, verbose = FALSE, gc = TRUE) {
  
  verbose <- isTRUE(verbose)
  
  if(verbose) message("Writing dataset [2/3].")
  stopifnot(mread_with_ds(x@mod))
  stopifnot(inherits(x, "mrgsims"))
  
  dir <- get_mread_tempdir(x@mod)

  file <- file.path(dir, file_ds())
  if(grepl(" ", file)) {
    abort("output file name cannot contain spaces.")  
  }
  
  write_parquet(x = x@data, sink = file)
  
  if(verbose) message("Wrapping up [3/3].")
  
  ans <- new.env(parent = emptyenv())
  ans$ds <- open_dataset(file)
  ans$files <- ans$ds$files
  ans$hash <- character(0)
  ans$mod <- x@mod
  ans$dim <- dim(ans$ds)
  n <- min(10, ans$dim[1L])
  ans$head <- x@data[seq(n),]
  ans$names <- names(ans$head)
  ans$variables <- intersect(c(x@request, x@outnames), ans$names)
  ans$pid <- Sys.getpid()
  ans$gc <- isTRUE(gc)
  ans$gc_notify <- FALSE
  ans$address <- obj_addr(ans)
  
  rm(x)

  if(isTRUE(ans$gc)) {
    set_finalizer_ds(ans)
  }

  class(ans) <- c("mrgsimsds", "environment")
  
  take_ownership(ans)
    
  ans
}

#' Simulate from a model object, returning an 'Apache' 'Arrow'-backed output object
#' 
#' All simulation data is saved to `tempdir()` according to the parent or head
#' node that the computation is run from. See [move_ds()] to [write_ds()]
#' change the location of the files, protecting them from the garbage collector.
#' Note that full names must be used for all arguments. 
#' 
#' @param x a model object loaded through [mread_ds()], [mcode_ds()], 
#' [modlib_ds()], [mread_cache_ds()], or [house_ds()].
#' @param ... passed to [mrgsolve::mrgsim()]. 
#' @param tags a named list of atomic data to tag (or mutate) the simulated 
#' output.
#' @param verbose if `TRUE`, print progress information to the console.
#' @param gc if `TRUE`, a finalizer function will attempt to remove files once 
#' the object is out of scope; set to `FALSE` to protect from automatic 
#' cleanup. Otherwise, move the files from `tempdir()` 
#' 
#' @examples
#' mod <- house_ds()
#' 
#' data <- ev_expand(amt = 100, ID = 1:10)
#' 
#' out <- mrgsim_ds(mod, data, end = 72, delta = 0.1)
#' 
#' out <- mrgsim_ds(mod, data, tags = list(rep = 1))
#' 
#' head(out)
#' 
#' @return 
#' An object with class `mrgsimsds`.
#' 
#' @seealso [as_mrgsim_ds()], [mrgsimsds-methods].
#' 
#' @export
mrgsim_ds <- function(x,  ..., tags = list(), verbose = FALSE, 
                      gc = TRUE) {
  verbose <- isTRUE(verbose)
  if(verbose) message("Simulating data [1/3].")
  out <- mrgsim(x, output = NULL, ...)
  if(is.list(tags) && length(tags)) {
    if(!is_named(tags)) {
      abort("`tags` must be a named list.")  
    }
    for(j in names(tags)) {
      out@data[[j]] <- tags[[j]]  
    }
  }
  ans <- as_mrgsim_ds(x = out, verbose = verbose, gc = gc)
  ans
}

#' Interact with mrgsimsds objects
#' 
#' @param x an mrgsimsds object, output from 
#' [mrgsim_ds()] or [as_mrgsim_ds()].
#' @param y a formula for plotting simulated data; if not provided, all 
#' columns will be plotted. 
#' @param n number of rows to return.
#' @param nid number of subjects to plot.
#' @param batch_size size of batch when reading data for plot method.
#' @param logy if `TRUE`, plot data with log y-axis.
#' @param .dots a list of items to pass to [mrgsolve::plot_sims()].
#' @param ... arguments to be passed to or from other methods.
#' 
#' @details
#' `head()` and `tail()` only look at the first and last `file` in the data 
#' set, respectively, when simulations are stored across multiple files. It is 
#' possible this won't correspond to the first and last chunks rows of data
#' you will see when collecting the data via [dplyr::collect()].
#' 
#' @examples
#' mod <- house_ds(end = 24)
#' 
#' mod <- omat(mod, diag(0.04, 4))
#' 
#' data <- ev_expand(amt = c(100, 300), ID = 1:20)
#' 
#' set.seed(10203)
#' 
#' out <- mrgsim_ds(mod, data = data)
#' 
#' dim(out)
#' head(out)
#' tail(out)
#' nrow(out)
#' ncol(out)
#' plot(out, ~ CP + RESP, nid = 10)
#' 
#' @name mrgsimsds-methods
#' @export
dim.mrgsimsds <- function(x) {
  x$dim
}

#' @name mrgsimsds-methods
#' @export
head.mrgsimsds <-  function(x, n = 6L, ...) {
  check_files_fatal(x)
  x <- safe_ds(x)
  as_tibble(get_nrow_from_ds(x, n = n))
}

#' @name mrgsimsds-methods
#' @export
tail.mrgsimsds <- function(x, n = 6L, ...) {
  check_files_fatal(x)
  x <- safe_ds(x)
  nf <- length(x$files)
  if(nf > 1) {
    ds <- open_dataset(x$files[nf])  
  } else {
    ds <- x$ds  
  }
  out <- tail(ds, n = n)
  collect(out)
}

#' @name mrgsimsds-methods
#' @export
names.mrgsimsds <- function(x) {
  names(x$ds)  
}

#' @name mrgsimsds-methods
#' @export
plot.mrgsimsds <- function(x, y = NULL, ...,  nid = 16, batch_size = 20000, 
                           logy = FALSE, .dots = list()) {
  check_files_fatal(x)
  sims <- get_nid_from_ds(x, nid = nid, batch_size = batch_size)
  if(length(unique(sims$ID)) < nid) {
    sims$ID <- consecutive_id(sims$ID)  
  }
  if(!is_formula(y)) {
    cols <- intersect(x$variables, x$names)
    y <- paste0(cols, collapse = "+")
    y <- paste0("~", y)
    y <- as.formula(y, env = emptyenv())
  }
  .dots$logy <- logy
  p <- plot_sims(sims, .f = y, .dots = .dots)
  p
}
