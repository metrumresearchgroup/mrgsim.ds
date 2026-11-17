# Get names of backing files

Get names of backing files

## Usage

``` r
files_ds(x)
```

## Arguments

- x:

  an mrgsimsds object.

## Value

A character vector of absolute paths to the parquet files backing `x`.

## See also

[`move_ds()`](https://metrumresearchgroup.github.io/mrgsim.ds/reference/move_ds.md),
[`save_ds()`](https://metrumresearchgroup.github.io/mrgsim.ds/reference/save_ds.md)

## Examples

``` r
mod <- house_ds()
out <- mrgsim_ds(mod)
files_ds(out)
#> [1] "/tmp/RtmpkdcWHK/mrgsim.ds-19aa3be25118/mrgsims-ds-19aa2943c1c8.parquet"
```
