#' Coerce an mrgsimsds object to an arrow table
#' 
#' @param x an mrgsimsds object. 
#' @param ... passed to [arrow::as_arrow_table()]. 
#' @param schema passed to [arrow::as_arrow_table()].
#' 
#' @examples
#' mod <- house_ds(end = 5)
#' 
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#' 
#' arrow::as_arrow_table(out)
#' 
#' @return
#' An 'Apache' 'Arrow' [arrow::Table] of simulated data.
#'
#' @export
as_arrow_table.mrgsimsds <- function(x, ..., schema = NULL) {
  x <- safe_ds(x)
  check_files_fatal(x)
  as_arrow_table(x$ds, ...)
}

#' Coerce an mrgsimsds object to a tbl
#' 
#' @param x an mrgsimsds object. 
#' @param row.names passed to [base::as.data.frame()]. 
#' @param optional passed to [base::as.data.frame()].
#' @param ... passed to [dplyr::as_tibble()] or [dplyr::collect()]. 
#' 
#' @examples
#' mod <- house_ds(end = 5)
#' 
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#' 
#' as.data.frame(out)
#' 
#' tibble::as_tibble(out)
#' 
#' dplyr::collect(out)
#' 
#' @return
#' A `tbl` containing simulated data. 
#'
#' @export
as_tibble.mrgsimsds <- function(x, ...) {
  x <- safe_ds(x)
  check_files_fatal(x)
  dplyr::as_tibble(x$ds, ...)  
}

#' @rdname as_tibble.mrgsimsds
#' @export
collect.mrgsimsds <- function(x, ...) {
  x <- safe_ds(x)
  check_files_fatal(x)
  dplyr::collect(x$ds, ... )  
}

#' @rdname as_tibble.mrgsimsds
#' @export
as.data.frame.mrgsimsds <- function(x, row.names = NULL, optional = FALSE, ...) {
  x <- safe_ds(x)
  check_files_fatal(x)
  as.data.frame(
    dplyr::collect(x$ds), 
    row.names = row.names, 
    optional = optional, 
    ...
  )
}

#' Coerce an mrgsimsds object to an arrow data set
#'
#' Extracts the underlying [arrow::Dataset] from an mrgsimsds object, allowing
#' you to work directly with the Arrow API or pass the dataset to other
#' Arrow-aware tools. For a list, only `mrgsimsds` elements are retained and
#' a single dataset spanning all their files is returned.
#'
#' @param x an mrgsimsds object or a list of mrgsimsds objects.
#' @param ... not used.
#' 
#' @examples
#' mod <- house_ds(end = 5)
#' 
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#' 
#' as_arrow_ds(out)
#' 
#' @return
#' An 'Apache' 'Arrow' [arrow::Dataset] object.
#' 
#' @export
as_arrow_ds <- function(x, ... ) UseMethod("as_arrow_ds")
#' @rdname as_arrow_ds
#' @export
as_arrow_ds.mrgsimsds <- function(x, ...) {
  x <- safe_ds(x)
  check_files_fatal(x)
  x$ds
}

#' Coerce an mrgsimsds object to a DuckDB table
#' 
#' @param x an mrgsimsds object or a list of mrgsimsds objects. 
#' @param ... passed to [as_arrow_ds()]. 
#' 
#' @description
#' The conversion is handled by [as_arrow_ds()].
#'
#' @examples
#' mod <- house_ds(end = 5)
#' 
#' out <- mrgsim_ds(mod, events = ev(amt = 100))
#' 
#' if(requireNamespace("duckdb")) {
#'   as_duckdb_ds(out)
#' }
#' 
#' @return
#' A `tbl` of the simulated data in DuckDB; see [arrow::to_duckdb()].
#' 
#' @seealso [as_arrow_ds()]
#' 
#' @export
as_duckdb_ds <- function(x, ...) UseMethod("as_duckdb_ds")
#' @export
as_duckdb_ds.mrgsimsds <- function(x, ...) {
  to_duckdb(as_arrow_ds(x, ...))  
}
