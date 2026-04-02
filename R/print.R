#' Print an mrgsimsds object
#'
#' @param x an mrgsimsds object.
#' @param n number of rows to show from the cached head data.
#' @param ... not used.
#'
#' @return `x` invisibly.
#'
#' @examples
#' mod <- house_ds(end = 24)
#'
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#'
#' print(out)
#'
#' @export
print.mrgsimsds <- function(x, n = 8, ...) { # nocov start
  check_files_fatal(x)
  dm <- x$dim
  size <- total_size(x$files)
  dm1 <- dm[1L]
  if(dm1 < 99999) {
    dm1 <- format(dm1, scientific = FALSE,  big.mark = ',')
  } else {
    dm1 <- format_big()(dm1)
  }
  owner <- check_ownership(x)
  own <- ifelse(owner, "yes", "no")
  if(owner) {
    own <- paste0(own, ifelse(x$gc, " (gc)", " (no gc)"))  
  }
  nfile <- sum(file.exists(x$files))
  cat("Model: ", x$mod@model, "\n", sep = "")
  cat("Dim  : ", dm1, " x ", dm[2L], "\n", sep = "")
  cat("Files: ", nfile, " [", size, "]", "\n", sep = "")
  cat("Owner: ", own, "\n", sep = "")
  chunk <- head(x$head, n = n)
  rownames(chunk) <- paste0(seq(nrow(chunk)), ": ")
  print(chunk) 
  if(invalid_ds(x)) {
    x <- refresh_ds(x)
    message("[mrgsim.ds] pointer and source pid refreshed.")
  }
  return(invisible(x))
} # nocov end
