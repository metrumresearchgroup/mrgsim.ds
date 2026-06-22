# Coerce an mrgsimsds object to an arrow data set

Extracts the underlying
[arrow::Dataset](https://arrow.apache.org/docs/r/reference/Dataset.html)
from an mrgsimsds object, allowing you to work directly with the Arrow
API or pass the dataset to other Arrow-aware tools. For a list, only
`mrgsimsds` elements are retained and a single dataset spanning all
their files is returned.

## Usage

``` r
as_arrow_ds(x, ...)

# S3 method for class 'mrgsimsds'
as_arrow_ds(x, ...)
```

## Arguments

- x:

  an mrgsimsds object or a list of mrgsimsds objects.

- ...:

  not used.

## Value

An 'Apache' 'Arrow'
[arrow::Dataset](https://arrow.apache.org/docs/r/reference/Dataset.html)
object.

## Examples

``` r
mod <- house_ds(end = 5)

out <- mrgsim_ds(mod, events = ev(amt = 100))

as_arrow_ds(out)
#> FileSystemDataset with 1 Parquet file
#> 7 columns
#> ID: double
#> time: double
#> GUT: double
#> CENT: double
#> RESP: double
#> DV: double
#> CP: double
#> 
#> See $metadata for additional Schema metadata
```
