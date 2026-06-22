# Simulate from a model object, returning an 'Apache' 'Arrow'-backed output object

Runs
[`mrgsolve::mrgsim()`](https://mrgsolve.org/docs/reference/mrgsim.html)
and writes simulation output to a parquet file in
[`tempdir()`](https://rdrr.io/r/base/tempfile.html), returning an
`mrgsimsds` object. Files in
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) are auto-deleted on
garbage collection by default. Use
[`move_ds()`](https://p-emex.github.io/mrgsim.ds/reference/move_ds.md)
or
[`save_ds()`](https://p-emex.github.io/mrgsim.ds/reference/save_ds.md)
to relocate files outside
[`tempdir()`](https://rdrr.io/r/base/tempfile.html), which automatically
disables gc, or call
[`gc_ds()`](https://p-emex.github.io/mrgsim.ds/reference/gc_ds.md) to
control gc directly. Note that full argument names must be used for all
arguments.

## Usage

``` r
mrgsim_ds(x, ..., tags = list(), verbose = FALSE, gc = TRUE)
```

## Arguments

- x:

  a model object loaded through
  [`mread_ds()`](https://p-emex.github.io/mrgsim.ds/reference/mread_ds.md),
  [`mcode_ds()`](https://p-emex.github.io/mrgsim.ds/reference/mread_ds.md),
  [`modlib_ds()`](https://p-emex.github.io/mrgsim.ds/reference/mread_ds.md),
  [`mread_cache_ds()`](https://p-emex.github.io/mrgsim.ds/reference/mread_ds.md),
  or
  [`house_ds()`](https://p-emex.github.io/mrgsim.ds/reference/mread_ds.md).

- ...:

  passed to
  [`mrgsolve::mrgsim()`](https://mrgsolve.org/docs/reference/mrgsim.html).

- tags:

  a named list of atomic data to tag (or mutate) the simulated output.

- verbose:

  if `TRUE`, print progress information to the console.

- gc:

  initial gc setting; if `TRUE`, a finalizer function will attempt to
  remove files once the object is out of scope. This value is not
  locked:
  [`move_ds()`](https://p-emex.github.io/mrgsim.ds/reference/move_ds.md)
  and
  [`save_ds()`](https://p-emex.github.io/mrgsim.ds/reference/save_ds.md)
  will automatically adjust gc based on whether the files remain under
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html). To lock the gc
  setting and prevent automatic adjustment, call
  [`gc_ds()`](https://p-emex.github.io/mrgsim.ds/reference/gc_ds.md)
  after creation.

## Value

An object with class `mrgsimsds`.

## See also

[`as_mrgsim_ds()`](https://p-emex.github.io/mrgsim.ds/reference/as_mrgsim_ds.md),
[mrgsimsds-methods](https://p-emex.github.io/mrgsim.ds/reference/mrgsimsds-methods.md).

## Examples

``` r
mod <- house_ds()

data <- ev_expand(amt = 100, ID = 1:10)

out <- mrgsim_ds(mod, data, end = 72, delta = 0.1)

out <- mrgsim_ds(mod, data, tags = list(rep = 1))

head(out)
#> # A tibble: 6 × 8
#>      ID  time   GUT  CENT  RESP    DV    CP   rep
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1     1  0      0     0    50    0     0        1
#> 2     1  0    100     0    50    0     0        1
#> 3     1  0.25  74.1  25.7  48.7  1.29  1.29     1
#> 4     1  0.5   54.9  44.5  46.2  2.23  2.23     1
#> 5     1  0.75  40.7  58.1  43.6  2.90  2.90     1
#> 6     1  1     30.1  67.8  41.4  3.39  3.39     1
```
