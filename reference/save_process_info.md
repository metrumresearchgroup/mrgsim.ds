# Save information about the R process that loaded a model

Stamps the model object with the current process ID and
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) path so that
[`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md)
knows where to write output files. This is called automatically by
[`mread_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md),
[`house_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md),
and the other model-loading wrappers. Call it directly only when you
load a model through the base mrgsolve functions (e.g.
[`mrgsolve::mread()`](https://mrgsolve.org/docs/reference/mread.html))
and still want to use
[`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md).

## Usage

``` r
save_process_info(x)
```

## Arguments

- x:

  a model object.

## Value

An updated model object suitable for using with
[`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md).

## Examples

``` r
mod <- mrgsolve::house()

mod <- save_process_info(mod)
```
