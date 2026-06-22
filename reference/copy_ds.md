# Copy an mrgsimsds object

Creates a new mrgsimsds object pointing to the same parquet files as
`x`. By default the new object takes ownership of those files, which
means the original object loses ownership and its files will not be
deleted when it is garbage collected.

## Usage

``` r
copy_ds(x, own = TRUE)
```

## Arguments

- x:

  an mrgsimsds object to copy.

- own:

  logical; if `TRUE` the new object takes ownership of the files; if
  `FALSE` ownership is left unchanged.

## Value

A new mrgsimsds object with the same files and fields as `x`, a fresh
memory address, and `pid` set to the current process.

## Examples

``` r
mod <- house_ds()

out <- mrgsim_ds(mod)

out2 <- copy_ds(out)

check_ownership(out)
#> [1] FALSE

check_ownership(out2)
#> [1] TRUE
```
