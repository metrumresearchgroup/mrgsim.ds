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
#> 1 mrgsims-ds-1953362f5834.parquet 0x55aafb384090
#> 2 mrgsims-ds-1953740c638b.parquet 0x55aafd5ad2b8
#> 3 mrgsims-ds-1953694c749b.parquet 0x55aaf8ef4bb8
#> 4  mrgsims-ds-19536d80c8f.parquet 0x55aafaa677d8
#> 5   mrgsims-ds-1953e99009.parquet 0x55aafe304138
#> 6 mrgsims-ds-195353658bc9.parquet 0x55aafb3d4ac8
#> 7 mrgsims-ds-1953393fc529.parquet 0x55aafb5d7b78

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
