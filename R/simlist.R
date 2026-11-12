simlist_classes <- function(x) {
  inh <- vapply(
    x,
    inherits,
    "mrgsimsds",
    FUN.VALUE = TRUE,
    USE.NAMES = FALSE
  )
  inh
}

simlist_models <- function(x) {
  models <- vapply(
    x,
    FUN = \(xi) xi$model,
    FUN.VALUE = "model",
    USE.NAMES = FALSE
  )
  models_equal <- models==models[1]
  models_equal
}

simlist_cols <- function(x) {
  cols_names <- lapply(x, \(xi) xi$names)
  cols_equal <- vapply(
    cols_names,
    FUN = setequal,
    FUN.VALUE = TRUE,
    USE.NAMES = FALSE,
    y = cols_names[[1]]
  )
  cols_equal
}

# Return the files from a simlist
simlist_files <- function(x) {
  files <- lapply(x, \(xi) xi$files)
  unlist(files, use.names = FALSE)
}

simlist_can_own <- function(x) {
  owns <- vapply(
    x, 
    FUN = can_take_ownership, 
    FUN.VALUE = TRUE, 
    USE.NAMES = FALSE
  )
  owns
}
