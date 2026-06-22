# Check if object inherits mrgsimsds

Check if object inherits mrgsimsds

## Usage

``` r
is_mrgsimsds(x)
```

## Arguments

- x:

  object to check.

## Value

`TRUE` if `x` inherits from `mrgsimsds`; `FALSE` otherwise.

## Examples

``` r
mod <- house_ds()

out <- mrgsim_ds(mod, events = ev(amt = 100))

is_mrgsimsds(out)
#> [1] TRUE

is_mrgsimsds(list())
#> [1] FALSE
```
