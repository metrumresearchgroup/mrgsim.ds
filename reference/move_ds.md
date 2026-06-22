# Move, rename, combine files in mrgsimsds objects

Use `move_ds()` to change the enclosing directory. `rename_ds()` keeps
the files in place, but changes the file names. `combine_ds()` brings
simulated data from multiple backing file into a single file.

### Automatic gc adjustment

Only `move_ds()` automatically updates the gc flag based on where the
files end up: files that remain under
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) keep `gc = TRUE`;
files moved outside [`tempdir()`](https://rdrr.io/r/base/tempfile.html)
get `gc = FALSE`, protecting them from automatic deletion. Neither
`rename_ds()` nor `combine_ds()` changes the gc flag because neither
changes the file location.

This automatic adjustment is skipped if the gc setting has been locked
by a prior call to
[`gc_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/gc_ds.md). A
warning is issued if gc is locked to `TRUE` but files land outside
[`tempdir()`](https://rdrr.io/r/base/tempfile.html).

The object (`x`) is required to own the underlying files in order to
move, rename, or combine them.

All three functions modify `x` in place and file ownership stays with
`x`.

## Usage

``` r
move_ds(x, path, quietly = FALSE)

rename_ds(x, id)

combine_ds(x)
```

## Arguments

- x:

  an mrgsimsds object.

- path:

  the new directory location for backing files.

- quietly:

  if `FALSE`, a message is printed about the potentially new location of
  the backing files on move.

- id:

  a short name used to create data set files for the simulated output.

## Value

All three functions return `x` invisibly. The updated file list is
accessible via `x$files`.

## See also

[`save_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/save_ds.md),
[`files_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/files_ds.md),
[`gc_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/gc_ds.md)

## Examples

``` r

mod <- house_ds()

out <- lapply(1:3, \(x) { mrgsim_ds(mod, events = ev(amt = 100)) })

out <- reduce_ds(out)

out <- rename_ds(out, "new-name")

out$files
#> [1] "/tmp/RtmprRxwQQ/mrgsims-ds-new-name-1.parquet"
#> [2] "/tmp/RtmprRxwQQ/mrgsims-ds-new-name-2.parquet"
#> [3] "/tmp/RtmprRxwQQ/mrgsims-ds-new-name-3.parquet"

out <- combine_ds(out)

out$files
#> [1] "/tmp/RtmprRxwQQ/mrgsims-ds-1a7df9deb28.parquet"
```
