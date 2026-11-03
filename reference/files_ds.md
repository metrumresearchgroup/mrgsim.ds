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
#> [1] "/tmp/RtmpM5vrGL/mrgsim.ds-18eb42b03cd6/mrgsims-ds-18eb688b22f8.parquet"
```
