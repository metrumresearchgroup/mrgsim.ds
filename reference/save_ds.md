# Save and restore an mrgsimsds object

`save_ds()` serializes an mrgsimsds object to an `.rds` file, moving the
backing parquet files to the same directory as `file`. Parquet filenames
are stored as bare basenames inside the `.rds`, so the `.rds` file and
its parquet files must stay in the same directory to be portable. **Do
not restore the file with
[`readRDS()`](https://rdrr.io/r/base/readRDS.html)**; use `read_ds()`
instead.

`read_ds()` deserializes a file written by `save_ds()`, rebuilds the
Arrow Dataset pointer, and transfers full ownership of the backing files
to the returned object.

## Usage

``` r
save_ds(x, file, quietly = FALSE)

read_ds(file)
```

## Arguments

- x:

  an mrgsimsds object.

- file:

  for `save_ds()`, the path to the output `.rds` file; the directory
  component determines where backing parquet files are moved. For
  `read_ds()`, the path to an `.rds` file written by `save_ds()`.

- quietly:

  if `FALSE`, a message is printed about the potentially new location of
  the backing files on move.

## Value

`save_ds()` returns the path to the written `.rds` file, invisibly.

`read_ds()` returns the restored mrgsimsds object invisibly. gc is
disabled (`gc = FALSE`) on the returned object and the caller holds
ownership of the backing files.

## See also

[`move_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md),
[`gc_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/gc_ds.md)

## Examples

``` r
mod <- house_ds()

out <- mrgsim_ds(mod, events = ev(amt = 100))

file <- save_ds(out, file.path(tempdir(), "out.rds"))
#> Warning: object and backing files will be saved to tempdir().

out2 <- read_ds(file)
```
