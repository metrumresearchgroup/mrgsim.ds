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
#> [1] "/tmp/RtmpdrVZyr/mrgsim.ds-18dc1d3c5147/mrgsims-ds-18dc20f7cd76.parquet"
```
