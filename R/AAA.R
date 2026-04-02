#' @importFrom rlang abort warn inform caller_env is_named is_formula
#' @importFrom arrow open_dataset  write_parquet Scanner
#' @importFrom arrow to_duckdb as_arrow_table
#' @importFrom dplyr collect distinct pull summarise summarize rename
#' @importFrom dplyr mutate select group_by filter bind_rows arrange
#' @importFrom dplyr consecutive_id count relocate
#' @importFrom tibble as_tibble
#' @importFrom utils head tail
#' @importFrom scales label_number cut_short_scale
#' @importFrom glue glue glue_data
#' @importFrom mrgsolve mrgsim ev ev_expand evd_expand house
#' @importFrom mrgsolve mread mcode mread_cache modlib house
#' @importFrom mrgsolve plot_sims is.mrgmod
#' @importFrom methods new
#' @importFrom fs file_move file_copy dir_exists dir_create file_delete path_norm
#' @importFrom stats as.formula
#' @importFrom lobstr obj_addr
#' @importFrom digest getVDigest
NULL

# nocov start
.global <- new.env(parent = emptyenv())
assign("file.prefix", "mrgsims-ds-", .global)
assign("file.re", "^mrgsims-ds-.*\\.parquet$", .global)
assign("nullptr", new("externalptr"), .global)

.onLoad <- function(libname, pkgname) {
  assign("trashcan", file.path(tempdir(), "mrgsim-ds-trash-can_"), .global)
  dir.create(.global$trashcan)
} # nocov end

#' @section Package-wide options:
#'
#' - `mrgsim.ds.show.gc`: print messages to the console when object files are
#'   removed prior to object cleanup.
#'
#'
#' @description
#' `mrgsim.ds` provides an [Apache Arrow](https://arrow.apache.org/docs/r/)-backed
#' simulation output object for [mrgsolve](https://mrgsolve.org), greatly reducing
#' the memory footprint of large simulations and providing a high-performance
#' pipeline for summarizing huge simulation outputs. The arrow-based simulation
#' output objects in R claim ownership of their files on disk.
#' Those files are automatically removed when the owning object goes out of scope
#' and becomes subject to the R garbage collector. While "anonymous",
#' parquet-formatted files hold the data in `tempdir()` as you are working in
#' R, functions are provided to move this data to more permanent locations for
#' later use.
#'
#' @section Function listing:
#'
#' - Load models
#'   - [mread_ds()]
#'   - [mcode_ds()]
#'   - [mread_cache_ds()]
#'   - [modlib_ds()]
#'   - [house_ds()]
#'
#' - Generate Apache Arrow dataset-backed outputs
#'   - [mrgsim_ds()]
#'   - [as_mrgsim_ds()]
#'
#' - S3 Methods
#'   - [head.mrgsimsds()]
#'   - [tail.mrgsimsds()]
#'   - [dim.mrgsimsds()]
#'   - [names.mrgsimsds()]
#'
#' - Move or rename files
#'   - [rename_ds()]
#'   - [move_ds()]
#'   - [write_ds()]
#'
#' - Ownership
#'   - [ownership()]
#'   - [check_ownership()]
#'   - [list_ownership()]
#'   - [take_ownership()]
#'   - [disown()]
#'   - [copy_ds()]
#'
#' - Work with lists of outputs
#'   - [reduce_ds()]
#'   - [refresh_ds()]
#'   - [prune_ds()]
#'
#' - Manage tempdir
#'   - [list_temp()]
#'   - [retain_temp()]
#'   - [purge_temp()]
#'
#' - Enter dplyr / arrow pipelines with
#'   - [dplyr::mutate()]
#'   - [dplyr::select()]
#'   - [dplyr::filter()]
#'   - [dplyr::summarise()]
#'   - [dplyr::summarize()]
#'   - [dplyr::rename()]
#'   - [dplyr::arrange()]
#'   - [dplyr::group_by()]
#'   - [dplyr::distinct()]
#'   - [dplyr::relocate()]
#'   - [dplyr::count()]
#'   - [dplyr::pull()]
#'
#' - Coerce to R objects
#'   - [as.data.frame()]
#'   - [dplyr::as_tibble()]
#'   - [dplyr::collect()]
#'   - [as_arrow_ds()]
#'   - [arrow::as_arrow_table()]
#'   - [as_duckdb_ds()]
#'
#' @examples
#'
#' mod <- house_ds(end = 32)
#'
#' data <- evd_expand(amt = seq(100, 300, 10))
#'
#' out <- mrgsim_ds(mod, data)
#'
#' out
#'
#' head(out)
#'
#' tail(out)
#'
#' plot(out, nid = 10)
#'
#' list_temp()
#'
#' ownership()
#'
#' \dontrun{
#'
#' rename_ds(out, "reg-100-300")
#'
#' list_temp()
#'
#' move_ds(out, "data/sim/regimens")
#' }
#'
#' @docType package
#' @name mrgsim.ds
#'
"_PACKAGE"
