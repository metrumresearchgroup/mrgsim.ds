# Coerce an mrgsimsds object to a DuckDB table

The conversion is handled by
[`as_arrow_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/as_arrow_ds.md).

## Usage

``` r
as_duckdb_ds(x, ...)
```

## Arguments

- x:

  an mrgsimsds object or a list of mrgsimsds objects.

- ...:

  passed to
  [`as_arrow_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/as_arrow_ds.md).

## Value

A `tbl` of the simulated data in DuckDB; see
[`arrow::to_duckdb()`](https://arrow.apache.org/docs/r/reference/to_duckdb.html).

## See also

[`as_arrow_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/as_arrow_ds.md)

## Examples

``` r
mod <- house_ds(end = 5)

out <- mrgsim_ds(mod, events = ev(amt = 100))

if(requireNamespace("duckdb")) {
  as_duckdb_ds(out)
}
#> Loading required namespace: duckdb
#> # A query:  ?? x 7
#> # Database: DuckDB 1.5.4 [unknown@Linux 6.17.0-1018-azure:R 4.6.0/:memory:]
#>       ID  time    GUT  CENT  RESP    DV    CP
#>    <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1     1  0      0      0    50    0     0   
#>  2     1  0    100      0    50    0     0   
#>  3     1  0.25  74.1   25.7  48.7  1.29  1.29
#>  4     1  0.5   54.9   44.5  46.2  2.23  2.23
#>  5     1  0.75  40.7   58.1  43.6  2.90  2.90
#>  6     1  1     30.1   67.8  41.4  3.39  3.39
#>  7     1  1.25  22.3   74.7  39.6  3.74  3.74
#>  8     1  1.5   16.5   79.6  38.2  3.98  3.98
#>  9     1  1.75  12.2   82.8  37.1  4.14  4.14
#> 10     1  2      9.07  85.0  36.4  4.25  4.25
#> # ℹ more rows
```
