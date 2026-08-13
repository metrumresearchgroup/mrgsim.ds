#' dplyr verbs for mrgsimsds objects
#'
#' Standard dplyr verbs dispatched on an mrgsimsds object. Each verb extracts
#' the underlying Arrow Dataset and forwards all arguments to the corresponding
#' dplyr generic, returning a lazy Arrow query that can be materialized with
#' [dplyr::collect()].
#'
#' @param .data,x an mrgsimsds object.
#' @param ... passed to the corresponding dplyr generic.
#' @param wt unsupported [dplyr::count()] argument.
#'
#' @return
#' A lazy Arrow query object. Use [dplyr::collect()] to materialize the result
#' into a tibble. `pull()` is an exception — it collects immediately and returns
#' a vector.
#'
#' @examples
#' library(dplyr)
#'
#' mod <- house_ds(end = 24)
#'
#' data <- evd_expand(amt = c(100, 300), ID = 1:10)
#'
#' out <- mrgsim_ds(mod, data)
#'
#' out |> filter(TIME > 0) |> select(ID, TIME, CP) |> collect()
#'
#' out |> group_by(ID) |> summarise(auc = sum(CP)) |> collect()
#'
#' out |> mutate(WEEK = TIME / 168) |> collect()
#'
#' @name mrgsimsds-verbs
#' @export
group_by.mrgsimsds <- function(.data, ...) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::group_by(as_arrow_ds(.data), ...)
}

#' @rdname mrgsimsds-verbs
#' @export
select.mrgsimsds <- function(.data, ...) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::select(as_arrow_ds(.data), ...)
}

#' @rdname mrgsimsds-verbs
#' @export
mutate.mrgsimsds <- function(.data, ...) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::mutate(as_arrow_ds(.data), ...)
}

#' @rdname mrgsimsds-verbs
#' @export
filter.mrgsimsds <- function(.data, ...) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::filter(as_arrow_ds(.data), ...)
}

#' @rdname mrgsimsds-verbs
#' @export
arrange.mrgsimsds <- function(.data, ...)  {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::arrange(as_arrow_ds(.data), ...)
}

#' @rdname mrgsimsds-verbs
#' @export
rename.mrgsimsds <- function(.data, ...) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::rename(as_arrow_ds(.data), ...)
}

#' @rdname mrgsimsds-verbs
#' @export
summarise.mrgsimsds <- function(.data, ...) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::summarise(as_arrow_ds(.data), ...)
}

#' @export
summarize.mrgsimsds <- summarise.mrgsimsds # nocov

#' @rdname mrgsimsds-verbs
#' @export
distinct.mrgsimsds <- function(.data, ...) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::distinct(as_arrow_ds(.data), ...)
}

#' @rdname mrgsimsds-verbs
#' @export
relocate.mrgsimsds <- function(.data, ...) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::relocate(as_arrow_ds(.data), ...)
}

#' @rdname mrgsimsds-verbs
#' @export
count.mrgsimsds <- function(x, ..., wt = NULL) {
  x <- safe_ds(x)
  check_files_fatal(x)
  if (!rlang::quo_is_null(rlang::enquo(wt))) {
    abort("the `wt` argument is not supported for mrgsimsds objects; call `as_arrow_ds()` first, then `count()`.")
  }
  dplyr::count(as_arrow_ds(x), ...)
}

#' @rdname mrgsimsds-verbs
#' @export
pull.mrgsimsds <- function(.data, ...) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::pull(as_arrow_ds(.data), ...)
}
