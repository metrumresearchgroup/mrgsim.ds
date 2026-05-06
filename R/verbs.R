#' dplyr verbs for mrgsimsds objects
#'
#' Standard dplyr verbs dispatched on an mrgsimsds object. Each verb extracts
#' the underlying Arrow Dataset and forwards all arguments to the corresponding
#' dplyr generic, returning a lazy Arrow query that can be materialized with
#' [dplyr::collect()].
#'
#' @param .data,x an mrgsimsds object.
#' @param ... passed to the corresponding dplyr generic.
#' @param .add,.drop passed to [dplyr::group_by()].
#' @param .groups passed to [dplyr::summarise()].
#' @param .preserve passed to [dplyr::filter()].
#' @param .by_group passed to [dplyr::arrange()].
#' @param .keep_all passed to [dplyr::distinct()].
#' @param .before,.after passed to [dplyr::relocate()].
#' @param as_vector passed to [dplyr::pull()].
#' @param var passed to [dplyr::pull()].
#' @param name passed to [dplyr::pull()].
#' @param wt,sort passed to [dplyr::count()].
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
group_by.mrgsimsds <- function(.data, ..., .add = FALSE, .drop = TRUE) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::group_by(as_arrow_ds(.data), ..., .add = .add, .drop = .drop)
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
filter.mrgsimsds <- function(.data, ..., .preserve = FALSE) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::filter(as_arrow_ds(.data), ..., .preserve = .preserve)
}

#' @rdname mrgsimsds-verbs
#' @export
arrange.mrgsimsds <- function(.data, ..., .by_group = FALSE)  {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::arrange(as_arrow_ds(.data), ..., .by_group = .by_group)
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
summarise.mrgsimsds <- function(.data, ..., .groups = NULL) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::summarise(as_arrow_ds(.data), ..., .groups = .groups)
}

#' @export
summarize.mrgsimsds <- summarise.mrgsimsds # nocov

#' @rdname mrgsimsds-verbs
#' @export
distinct.mrgsimsds <- function(.data, ..., .keep_all = FALSE) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::distinct(as_arrow_ds(.data), ..., .keep_all = .keep_all)
}

#' @rdname mrgsimsds-verbs
#' @export
relocate.mrgsimsds <- function(.data, ..., .before = NULL, .after = NULL) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::relocate(as_arrow_ds(.data), ..., .before = {{.before}}, .after = {{.after}})
}

#' @rdname mrgsimsds-verbs
#' @export
count.mrgsimsds <- function(x, ..., wt = NULL, sort = FALSE, name = NULL) {
  x <- safe_ds(x)
  check_files_fatal(x)
  if(!is.null(wt)) {
    abort("the `wt` argument is not supported for mrgsimsds objects; call `as_arrow_ds()` first, then `count()`.")
  }
  dplyr::count(as_arrow_ds(x), ..., sort = sort, name = name)
}

#' @rdname mrgsimsds-verbs
#' @export
pull.mrgsimsds <- function(.data, var = -1, name = NULL, as_vector = TRUE, ...) {
  .data <- safe_ds(.data)
  check_files_fatal(.data)
  dplyr::pull(as_arrow_ds(.data), var = {{var}}, name = {{name}}, as_vector = as_vector, ...)
}
