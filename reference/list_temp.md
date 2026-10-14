# Manage simulated outputs in the per-session temporary directory

Functions for inspecting and cleaning up package-managed parquet files
in the temporary directory. `list_temp()` shows what is present;
`purge_temp()` resets the simulation file system.

`purge_temp()` deletes all package-managed files unconditionally and
clears the ownership maps, resetting the system to a clean state. It is
intended for use in testing teardown or session cleanup, not routine
usage.

## Usage

``` r
list_temp(quietly = FALSE)

purge_temp(quietly = FALSE)
```

## Arguments

- quietly:

  if `TRUE`, suppresses console output (the file listing for
  `list_temp()` and the deletion summary for `purge_temp()`).

## Value

`list_temp()` returns a character vector of file paths invisibly, and
prints a summary to the console unless `quietly = TRUE`.

`purge_temp()` returns `NULL` invisibly.

## See also

[`set_tempdir_base()`](https://metrumresearchgroup.github.io/mrgsim.ds/reference/set_tempdir_base.md)

## Examples

``` r
mod <- house_ds()

out <- lapply(1:10, \(x) mrgsim_ds(mod))

list_temp()
#> 17 files [227.4 Kb]
#> - mrgsims-ds-190311ecd5cc.parquet
#> - mrgsims-ds-1903254150c7.parquet
#>    ...
#> - mrgsims-ds-19037bc49879.parquet
#> - mrgsims-ds-1903d523729.parquet

purge_temp()
#> Discarding 17 files.

list_temp()
#> No files in tempdir.
```
