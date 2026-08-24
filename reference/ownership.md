# Ownership of simulation files

Functions to check ownership or disown simulation output files on disk.

One situation where you need to take over ownership is when you are
simulating in parallel, and the simulation happens in another R process.
`mrgsim.ds` ownership is established when the simulation returns and the
`mrgsimsds` object is created. When this happens in another R process
(e.g., on a worker node), there is no way to transfer that information
back to the parent process. In that case, a call to `take_ownership()`
once the results are returned to the parent process would be
appropriate. Typically, these results are returned as a list and a call
to
[`reduce_ds()`](https://metrumresearchgroup.github.io/mrgsim.ds/reference/reduce_ds.md)
will create a single object pointing to and owning multiple files.
Therefore, it should be rare to call `take_ownership()` directly; if
doing so, please make sure you understand what is going on.

## Usage

``` r
ownership()

list_ownership(full.names = FALSE)

check_ownership(x)

disown(x)

take_ownership(x)
```

## Arguments

- full.names:

  if `TRUE`, include the directory path when listing file ownership.

- x:

  an mrgsimsds object.

## Value

- `check_ownership`: `TRUE` if `x` owns the underlying files; `FALSE`
  otherwise.

- `list_ownership`: a data.frame of ownership information.

- `ownership`: nothing; used for side effects.

- `disown`: `x` is returned invisibly; it is not modified.

- `take_ownership`: `x` is returned invisibly after its hash and the
  package-level ownership maps are updated in place.

## See also

[`reduce_ds()`](https://metrumresearchgroup.github.io/mrgsim.ds/reference/reduce_ds.md),
[`copy_ds()`](https://metrumresearchgroup.github.io/mrgsim.ds/reference/copy_ds.md).

## Examples

``` r
mod <- house_ds()

out <- mrgsim_ds(mod, id = 1)

check_ownership(out)
#> [1] TRUE

ownership()
#> > Objects: 7 | Files: 7 | Size: 385.7 Kb

list_ownership()
#>                              file        address
#> 1 mrgsims-ds-1a0b7ef867b6.parquet 0x55bbabaf5b20
#> 2 mrgsims-ds-1a0b1945a875.parquet 0x55bbb1aab2f0
#> 3 mrgsims-ds-1a0b1de8cbc3.parquet 0x55bbaed88a80
#> 4 mrgsims-ds-1a0b51f7ea2c.parquet 0x55bbaeb7c578
#> 5 mrgsims-ds-1a0b2567b9aa.parquet 0x55bbafbee010
#> 6 mrgsims-ds-1a0b39eadc57.parquet 0x55bbae2250e8
#> 7 mrgsims-ds-1a0b5745e50e.parquet 0x55bbb0d61940

e1 <- ev(amt = 100)
e2 <- ev(amt = 200)

out <- list(mrgsim_ds(mod, e1), mrgsim_ds(mod, e2))

sims <- reduce_ds(out)

ownership()
#> > Objects: 8 | Files: 9 | Size: 439 Kb

check_ownership(sims)
#> [1] TRUE

check_ownership(out[[1]])
#> [1] FALSE

check_ownership(out[[2]])
#> [1] FALSE

```
