# Load an mrgsolve model for Arrow-backed simulation

Thin wrappers around mrgsolve model-loading functions
([`mread()`](https://mrgsolve.org/docs/reference/mread.html),
[`mcode()`](https://mrgsolve.org/docs/reference/mcode.html),
[`modlib()`](https://mrgsolve.org/docs/reference/modlib.html),
[`house()`](https://mrgsolve.org/docs/reference/house.html),
[`mread_cache()`](https://mrgsolve.org/docs/reference/mread.html)) that
additionally call
[`save_process_info()`](https://p-emex.github.io/mrgsim.ds/reference/save_process_info.md)
to stamp the model with the current process ID. This stamp is required
by
[`mrgsim_ds()`](https://p-emex.github.io/mrgsim.ds/reference/mrgsim_ds.md)
to correctly associate simulation outputs with the process that created
them.

## Usage

``` r
mread_ds(...)

mcode_ds(...)

modlib_ds(...)

house_ds(...)

mread_cache_ds(...)
```

## Arguments

- ...:

  passed to the corresponding mrgsolve function.

## Value

A model object with process information saved, suitable for use with
[`mrgsim_ds()`](https://p-emex.github.io/mrgsim.ds/reference/mrgsim_ds.md).

## See also

[`save_process_info()`](https://p-emex.github.io/mrgsim.ds/reference/save_process_info.md).

## Examples

``` r
mod <- house_ds()

mod
#> 
#> 
#> --------------  source: housemodel.cpp  --------------
#> 
#>   project: /home/runner/wor...solve/project
#>   shared object: mrgsolve 
#> 
#>   time:          start: 0 end: 120 delta: 0.25
#>                  add: <none>
#>   compartments:  GUT CENT RESP [3]
#>   parameters:    CL VC KA F1 D1 WTCL WTVC SEXCL SEXVC
#>                  KIN KOUT IC50 WT SEX [14]
#>   captures:      DV CP [2]
#>   omega:         4x4 
#>   sigma:         1x1 
#> 
#>   solver:        rtol: 1e-08 atol: 1e-08 itol: 1 (scalar)
#> ------------------------------------------------------
```
