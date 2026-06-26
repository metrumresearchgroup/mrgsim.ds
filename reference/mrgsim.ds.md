# mrgsim.ds: 'Apache' 'Arrow' Dataset-Backed Simulation Outputs for 'mrgsolve'

`mrgsim.ds` provides an [Apache
Arrow](https://arrow.apache.org/docs/r/)-backed simulation output object
for [mrgsolve](https://mrgsolve.org), greatly reducing the memory
footprint of large simulations and providing a high-performance pipeline
for summarizing huge simulation outputs. The arrow-based simulation
output objects in R claim ownership of their files on disk. Those files
are automatically removed when the owning object goes out of scope and
becomes subject to the R garbage collector. While "anonymous",
parquet-formatted files hold the data in
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) as you are working
in R, functions are provided to move this data to more permanent
locations for later use.

## Package-wide options

- `mrgsim.ds.show.gc`: print messages to the console when object files
  are removed prior to object cleanup.

## Function listing

- Load models

  - [`mread_ds()`](https://p-emex.github.io/mrgsim.ds/reference/mread_ds.md)

  - [`mcode_ds()`](https://p-emex.github.io/mrgsim.ds/reference/mread_ds.md)

  - [`mread_cache_ds()`](https://p-emex.github.io/mrgsim.ds/reference/mread_ds.md)

  - [`modlib_ds()`](https://p-emex.github.io/mrgsim.ds/reference/mread_ds.md)

  - [`house_ds()`](https://p-emex.github.io/mrgsim.ds/reference/mread_ds.md)

- Generate Apache Arrow dataset-backed outputs

  - [`mrgsim_ds()`](https://p-emex.github.io/mrgsim.ds/reference/mrgsim_ds.md)

  - [`as_mrgsim_ds()`](https://p-emex.github.io/mrgsim.ds/reference/as_mrgsim_ds.md)

- S3 Methods

  - [`head.mrgsimsds()`](https://p-emex.github.io/mrgsim.ds/reference/mrgsimsds-methods.md)

  - [`tail.mrgsimsds()`](https://p-emex.github.io/mrgsim.ds/reference/mrgsimsds-methods.md)

  - [`dim.mrgsimsds()`](https://p-emex.github.io/mrgsim.ds/reference/mrgsimsds-methods.md)

  - [`names.mrgsimsds()`](https://p-emex.github.io/mrgsim.ds/reference/mrgsimsds-methods.md)

- Move, rename, or combine files

  - [`move_ds()`](https://p-emex.github.io/mrgsim.ds/reference/move_ds.md)

  - [`rename_ds()`](https://p-emex.github.io/mrgsim.ds/reference/move_ds.md)

  - [`combine_ds()`](https://p-emex.github.io/mrgsim.ds/reference/move_ds.md)

- Save and restore

  - [`save_ds()`](https://p-emex.github.io/mrgsim.ds/reference/save_ds.md)

  - [`read_ds()`](https://p-emex.github.io/mrgsim.ds/reference/save_ds.md)

  - [`write_parquet_ds()`](https://p-emex.github.io/mrgsim.ds/reference/write_parquet_ds.md)

  - [`write_dataset_ds()`](https://p-emex.github.io/mrgsim.ds/reference/write_parquet_ds.md)

- Ownership

  - [`ownership()`](https://p-emex.github.io/mrgsim.ds/reference/ownership.md)

  - [`check_ownership()`](https://p-emex.github.io/mrgsim.ds/reference/ownership.md)

  - [`list_ownership()`](https://p-emex.github.io/mrgsim.ds/reference/ownership.md)

  - [`take_ownership()`](https://p-emex.github.io/mrgsim.ds/reference/ownership.md)

  - [`disown()`](https://p-emex.github.io/mrgsim.ds/reference/ownership.md)

  - [`copy_ds()`](https://p-emex.github.io/mrgsim.ds/reference/copy_ds.md)

- Work with lists of outputs

  - [`reduce_ds()`](https://p-emex.github.io/mrgsim.ds/reference/reduce_ds.md)

  - [`refresh_ds()`](https://p-emex.github.io/mrgsim.ds/reference/refresh_ds.md)

  - [`prune_ds()`](https://p-emex.github.io/mrgsim.ds/reference/prune_ds.md)

- Manage tempdir

  - [`list_temp()`](https://p-emex.github.io/mrgsim.ds/reference/list_temp.md)

  - [`purge_temp()`](https://p-emex.github.io/mrgsim.ds/reference/list_temp.md)

- Enter dplyr / arrow pipelines with

  - [`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)

  - [`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html)

  - [`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html)

  - [`dplyr::summarise()`](https://dplyr.tidyverse.org/reference/summarise.html)

  - [`dplyr::summarize()`](https://dplyr.tidyverse.org/reference/summarise.html)

  - [`dplyr::rename()`](https://dplyr.tidyverse.org/reference/rename.html)

  - [`dplyr::arrange()`](https://dplyr.tidyverse.org/reference/arrange.html)

  - [`dplyr::group_by()`](https://dplyr.tidyverse.org/reference/group_by.html)

  - [`dplyr::distinct()`](https://dplyr.tidyverse.org/reference/distinct.html)

  - [`dplyr::relocate()`](https://dplyr.tidyverse.org/reference/relocate.html)

  - [`dplyr::count()`](https://dplyr.tidyverse.org/reference/count.html)

  - [`dplyr::pull()`](https://dplyr.tidyverse.org/reference/pull.html)

- Coerce to R objects

  - [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html)

  - [`dplyr::as_tibble()`](https://dplyr.tidyverse.org/reference/reexports.html)

  - [`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html)

  - [`as_arrow_ds()`](https://p-emex.github.io/mrgsim.ds/reference/as_arrow_ds.md)

  - [`arrow::as_arrow_table()`](https://arrow.apache.org/docs/r/reference/as_arrow_table.html)

  - [`as_duckdb_ds()`](https://p-emex.github.io/mrgsim.ds/reference/as_duckdb_ds.md)

## See also

Useful links:

- <https://github.com/p-emex/mrgsim.ds>

- <https://p-emex.github.io/mrgsim.ds/>

- Report bugs at <https://github.com/p-emex/mrgsim.ds/issues>

## Author

**Maintainer**: Kyle T Baron <kyleb@metrumrg.com>
([ORCID](https://orcid.org/0000-0001-7252-5656)) \[copyright holder\]

## Examples

``` r

mod <- house_ds(end = 32)

data <- evd_expand(amt = seq(100, 300, 10))

out <- mrgsim_ds(mod, data)

out
#> Model: housemodel
#> Dim  : 2,730 x 7
#> Files: 1 [129 Kb]
#> Owner: yes (gc)
#>     ID TIME       GUT     CENT     RESP       DV       CP
#> 1:   1 0.00   0.00000  0.00000 50.00000 0.000000 0.000000
#> 2:   1 0.00 100.00000  0.00000 50.00000 0.000000 0.000000
#> 3:   1 0.25  74.08182 25.74883 48.68223 1.287441 1.287441
#> 4:   1 0.50  54.88116 44.50417 46.18005 2.225208 2.225208
#> 5:   1 0.75  40.65697 58.08258 43.61333 2.904129 2.904129
#> 6:   1 1.00  30.11942 67.82976 41.37943 3.391488 3.391488
#> 7:   1 1.25  22.31302 74.74256 39.57649 3.737128 3.737128
#> 8:   1 1.50  16.52989 79.55944 38.18381 3.977972 3.977972

head(out)
#> # A tibble: 6 × 7
#>      ID  TIME   GUT  CENT  RESP    DV    CP
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1     1  0      0     0    50    0     0   
#> 2     1  0    100     0    50    0     0   
#> 3     1  0.25  74.1  25.7  48.7  1.29  1.29
#> 4     1  0.5   54.9  44.5  46.2  2.23  2.23
#> 5     1  0.75  40.7  58.1  43.6  2.90  2.90
#> 6     1  1     30.1  67.8  41.4  3.39  3.39

tail(out)
#> # A tibble: 6 × 7
#>      ID  TIME      GUT  CENT  RESP    DV    CP
#>   <dbl> <dbl>    <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1    21  30.8 4.71e-14  67.3  37.2  3.36  3.36
#> 2    21  31   3.49e-14  66.4  37.3  3.32  3.32
#> 3    21  31.2 2.58e-14  65.6  37.4  3.28  3.28
#> 4    21  31.5 1.91e-14  64.8  37.5  3.24  3.24
#> 5    21  31.8 1.42e-14  64.0  37.6  3.20  3.20
#> 6    21  32   1.05e-14  63.2  37.8  3.16  3.16

plot(out, nid = 10)


list_temp()
#> 1 files [129 Kb]
#> - mrgsims-ds-1a4e60c8511c.parquet

ownership()
#> > Objects: 1 | Files: 1 | Size: 129 Kb

if (FALSE) { # \dontrun{

rename_ds(out, "reg-100-300")

list_temp()

move_ds(out, "data/sim/regimens")
} # }
```
