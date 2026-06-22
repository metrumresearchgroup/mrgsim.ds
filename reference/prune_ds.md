# Prune a list of mrgsimsds objects

Filters a mixed list down to only the elements that are `mrgsimsds`
objects, dropping anything else (e.g. `NULL`, data frames, character
vectors). When passed a single `mrgsimsds` object it is returned
invisibly unchanged.

## Usage

``` r
prune_ds(x, ..., inform = TRUE)

# S3 method for class 'mrgsimsds'
prune_ds(x, ...)

# S3 method for class 'list'
prune_ds(x, ..., inform = TRUE)
```

## Arguments

- x:

  a list of R objects or a single mrgsimsds object.

- ...:

  not used.

- inform:

  (list method only) issue a message when objects in some list slots are
  dropped.

## Value

When `x` is a list, it will be returned with only the mrgsimsds objects
retained. If no mrgsimsds objects are found, an empty list is returned
with a warning.

When `x` is an mrgsimsds object, it will be invisibly returned.

## Examples

``` r
mod <- house_ds(end = 24)

out <- mrgsim_ds(mod, events = ev(amt = 100))

sims <- list(out, letters)

prune_ds(sims)
#> dropping 1 objects that are not mrgsimsds.
#> [[1]]
#> Model: housemodel
#> Dim  : 98 x 7
#> Files: 1 [7.4 Kb]
#> Owner: yes (gc)
#>     ID time       GUT     CENT     RESP       DV       CP
#> 1:   1 0.00   0.00000  0.00000 50.00000 0.000000 0.000000
#> 2:   1 0.00 100.00000  0.00000 50.00000 0.000000 0.000000
#> 3:   1 0.25  74.08182 25.74883 48.68223 1.287441 1.287441
#> 4:   1 0.50  54.88116 44.50417 46.18005 2.225208 2.225208
#> 5:   1 0.75  40.65697 58.08258 43.61333 2.904129 2.904129
#> 6:   1 1.00  30.11942 67.82976 41.37943 3.391488 3.391488
#> 7:   1 1.25  22.31302 74.74256 39.57649 3.737128 3.737128
#> 8:   1 1.50  16.52989 79.55944 38.18381 3.977972 3.977972
#> 
```
