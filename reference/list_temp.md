# Manage simulated outputs in the per-session temporary directory

Functions for inspecting and cleaning up package-managed parquet files
in [`tempdir()`](https://rdrr.io/r/base/tempfile.html). `list_temp()`
shows what is present; `purge_temp()` resets the simulation file system.

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

## Examples

``` r
mod <- house_ds()

out <- lapply(1:10, \(x) mrgsim_ds(mod))

list_temp()
#> 15 files [143.7 Kb]
#> - mrgsims-ds-194118a1836b.parquet
#> - mrgsims-ds-194122808281.parquet
#>    ...
#> - mrgsims-ds-194177f2e408.parquet
#> - mrgsims-ds-1941b8b664c.parquet

purge_temp()
#> Discarding 15 files.

list_temp()
#> No files in tempdir.
```
