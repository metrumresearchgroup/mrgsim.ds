# Set garbage collection behavior for mrgsimsds objects

Controls whether the underlying parquet files are automatically deleted
when the object is garbage collected (`value`) and whether a message is
issued when that deletion occurs (`notify`). Set `value = FALSE` to
protect files from cleanup; set back to `TRUE` to re-enable automatic
deletion. The `notify` flag is intended for debugging only; the
`mrgsim.ds.show.gc` option provides the same behavior package-wide.

Calling `gc_ds()` with `value` locks the gc setting: once a value is
explicitly set, the package will never automatically change it when
files are moved or written. A warning is issued if gc is locked to
`TRUE` but files are moved outside of
[`tempdir()`](https://rdrr.io/r/base/tempfile.html), since those files
would then be auto-deleted on garbage collection.

## Usage

``` r
gc_ds(x, value = NULL, notify = NULL, ...)

# S3 method for class 'mrgsimsds'
gc_ds(x, value = NULL, notify = NULL, ...)

# S3 method for class 'list'
gc_ds(x, value = NULL, notify = NULL, ...)
```

## Arguments

- x:

  an mrgsimsds object or a list of objects.

- value:

  logical; if `TRUE` the underlying files will be deleted on garbage
  collection. Passing any value also locks the gc setting so that
  subsequent file operations (see
  [`move_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md))
  do not automatically adjust it.

- notify:

  logical; if `TRUE` a message will be issued when files are deleted on
  garbage collection. For debugging only; see also the
  `mrgsim.ds.show.gc` option.

- ...:

  not used.

## Value

When `x` is an mrgsimsds object, it is returned invisibly with `gc`
and/or `gc_notify` updated.

When `x` is a list, it is returned invisibly with `gc_ds()` applied to
every mrgsimsds element; non-mrgsimsds elements are left unchanged.

## Examples

``` r
mod <- modlib_ds("popex", outvars = "IPRED")
#> Building popex ... 
#> done.

data <- ev_expand(amt = 100, ID = 1:5)

out <- mrgsim_ds(mod, data)

out <- gc_ds(out, value = FALSE)

out <- gc_ds(out, value = TRUE)

out <- lapply(1:3, function(rep) {
  out <- mrgsim_ds(mod, data)
  out
})

out <- gc_ds(out, value = FALSE)
```
