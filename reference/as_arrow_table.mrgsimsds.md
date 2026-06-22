# Coerce an mrgsimsds object to an arrow table

Coerce an mrgsimsds object to an arrow table

## Usage

``` r
# S3 method for class 'mrgsimsds'
as_arrow_table(x, ..., schema = NULL)
```

## Arguments

- x:

  an mrgsimsds object.

- ...:

  passed to
  [`arrow::as_arrow_table()`](https://arrow.apache.org/docs/r/reference/as_arrow_table.html).

- schema:

  passed to
  [`arrow::as_arrow_table()`](https://arrow.apache.org/docs/r/reference/as_arrow_table.html).

## Value

An 'Apache' 'Arrow' arrow::Table of simulated data.

## Examples

``` r
mod <- house_ds(end = 5)

out <- mrgsim_ds(mod, events = ev(amt = 100))

arrow::as_arrow_table(out)
#> Table
#> 22 rows x 7 columns
#> $ID <double>
#> $time <double>
#> $GUT <double>
#> $CENT <double>
#> $RESP <double>
#> $DV <double>
#> $CP <double>
#> 
#> See $metadata for additional Schema metadata
```
