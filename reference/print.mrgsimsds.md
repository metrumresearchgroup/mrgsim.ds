# Print an mrgsimsds object

Print an mrgsimsds object

## Usage

``` r
# S3 method for class 'mrgsimsds'
print(x, n = 8, ...)
```

## Arguments

- x:

  an mrgsimsds object.

- n:

  number of rows to show from the cached head data.

- ...:

  not used.

## Value

`x` invisibly.

## Examples

``` r
mod <- house_ds(end = 24)

out <- mrgsim_ds(mod, events = ev(amt = 100))

print(out)
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
```
