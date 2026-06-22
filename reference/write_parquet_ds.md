# Write simulations to a parquet file or partitioned dataset

Use these functions to escape the `mrgsim.ds` universe.
`write_parquet_ds()` writes all simulated data to a single `.parquet`
file. `write_dataset_ds()` writes to a directory, optionally
partitioned, via
[`arrow::write_dataset()`](https://arrow.apache.org/docs/r/reference/write_dataset.html);
the caller takes responsibility for the resulting files.

## Usage

``` r
write_parquet_ds(x, sink, ...)

write_dataset_ds(x, path, ...)
```

## Arguments

- x:

  an mrgsimsds object.

- sink:

  passed to
  [`arrow::write_parquet()`](https://arrow.apache.org/docs/r/reference/write_parquet.html).

- ...:

  passed to the underlying arrow function.

- path:

  passed to
  [`arrow::write_dataset()`](https://arrow.apache.org/docs/r/reference/write_dataset.html).

## Value

`write_parquet_ds()` returns `x` invisibly.

`write_dataset_ds()` returns `path` invisibly.

## See also

[`save_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/save_ds.md)
to persist an object while staying within the `mrgsim.ds` universe.
