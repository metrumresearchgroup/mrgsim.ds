#' Manage simulated outputs in the per-session temporary directory
#' 
#' @param ... objects whose files will not be purged.
#' 
#' @examples
#' mod <- house_ds()
#' 
#' out <- lapply(1:10, \(x) mrgsim_ds(mod))
#' 
#' list_temp()
#' 
#' sims <- reduce_ds(out)
#' 
#' list_temp()
#' 
#' retain_temp(sims)
#' 
#' list_temp() 
#' 
#' purge_temp() 
#' 
#' list_temp()
#' 
#' @export
list_temp <- function() {
  temp <- list.files(tempdir(), pattern = .global$file.re, full.names = TRUE)
  if(!length(temp)) {
    message("No files in tempdir.")
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
retain_temp <- function(...) {
  x <- list(...)
  cl <- simlist_classes(x)
  x <- x[cl]
  files <- lapply(x, \(xi) xi$files)
  files <- unlist(files, use.names = FALSE)
  temp <- list.files(tempdir(), pattern = .global$file.re, full.names = TRUE)
  temp <- temp[!(basename(temp) %in% basename(files))]
  message("Discarding ", length(temp), " files.")
  unlink(x = temp, recursive = TRUE)
  return(invisible(NULL))
}

#' @rdname list_temp
#' @export
purge_temp <- function() {
  temp <- list.files(tempdir(), pattern = .global$file.re, full.names = TRUE)
  message("Discarding ", length(temp), " files.")
  unlink(x = temp, recursive = TRUE)
  return(invisible(NULL))
}
