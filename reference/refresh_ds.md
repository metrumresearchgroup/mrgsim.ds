# Refresh 'Arrow' dataset pointers

Arrow dataset pointers become invalid when an object is created in a
worker process and returned to the head node (e.g. after a parallel
simulation). `refresh_ds()` rebuilds the pointer by re-opening the
parquet files via
[`arrow::open_dataset()`](https://arrow.apache.org/docs/r/reference/open_dataset.html)
and updates `pid` and `dim` in place. Because refreshing is itself the
fix for an invalid pointer, it checks that files exist but does not call
`safe_ds()` first.

## Usage

``` r
refresh_ds(x, ...)

# S3 method for class 'mrgsimsds'
refresh_ds(x, ...)

# S3 method for class 'list'
refresh_ds(x, ...)
```

## Arguments

- x:

  an mrgsimsds object or a list of objects.

- ...:

  for future use.

## Value

When `x` is an mrgsimsds object, it is returned invisibly with its Arrow
pointer, `pid`, and `dim` refreshed in place.

When `x` is a list, it is returned invisibly with `refresh_ds()` applied
to every mrgsimsds element; non-mrgsimsds elements are left unchanged.

## Examples

``` r
mod <- house_ds()

data <- ev_expand(amt = 100, ID = 1:100)

out <- lapply(1:3, function(rep) {
  mrgsim_ds(mod, data)
})

refresh_ds(out)
```
