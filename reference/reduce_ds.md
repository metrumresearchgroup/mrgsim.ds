# Reduce a list of mrgsimsds objects into a single object

Combines a list of mrgsimsds objects — typically the replicate outputs
from a parallel simulation — into one object backed by all of their
parquet files. Ownership of every file is transferred to the new object.

## Usage

``` r
reduce_ds(x, ...)

# S3 method for class 'mrgsimsds'
reduce_ds(x, ...)

# S3 method for class 'list'
reduce_ds(x, ...)
```

## Arguments

- x:

  a list of mrgsimsds objects or a single mrgsimsds object.

- ...:

  not used.

## Value

When `x` is a list, a new mrgsimsds object is returned that owns all
underlying parquet files; the input objects are disowned.

When `x` is an mrgsimsds object, it is validated, refreshed, and
returned invisibly with its `pid` updated to the current process.

## Details

### gc behavior

The returned object always gets a fresh, unlocked gc state: `gc_locked`
is set to `FALSE` and gc is determined by file location via the same
rule used at creation time — `TRUE` if files are under
[`tempdir()`](https://rdrr.io/r/base/tempfile.html), `FALSE` otherwise.
Any gc lock set on the input objects is not carried over. To lock the gc
setting on the result, call
[`gc_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/gc_ds.md)
after reducing.

## Examples

``` r
mod <- modlib_ds("popex", outvars = "IPRED")
#> Loading model from cache.

data <- ev_expand(amt = 100, ID = 1:10)

out <- lapply(1:3, function(rep) {
  out <- mrgsim_ds(mod, data) 
  out
})

length(out)
#> [1] 3

sims <- reduce_ds(out)

sims
#> Model: popex
#> Dim  : 14,460 x 3
#> Files: 3 [161.7 Kb]
#> Owner: yes (gc)
#>     ID time     IPRED
#> 1:   1  0.0 0.0000000
#> 2:   1  0.0 0.0000000
#> 3:   1  0.5 0.8629376
#> 4:   1  1.0 1.5462311
#> 5:   1  1.5 2.0850748
#> 6:   1  2.0 2.5077949
#> 7:   1  2.5 2.8371897
#> 8:   1  3.0 3.0916080

check_ownership(sims)
#> [1] TRUE

lapply(out, check_ownership)
#> [[1]]
#> [1] FALSE
#> 
#> [[2]]
#> [1] FALSE
#> 
#> [[3]]
#> [1] FALSE
#> 
```
