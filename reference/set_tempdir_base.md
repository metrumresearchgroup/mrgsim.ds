# Override the directory under which `mrgsim.ds` creates its temporary directory

By default, `mrgsim.ds` stores its files under a dedicated temporary
directory within [`tempdir()`](https://rdrr.io/r/base/tempfile.html).
Use `set_tempdir_base()` to specify an alternative location to
[`tempdir()`](https://rdrr.io/r/base/tempfile.html).

This is useful in scenarios where the work will be spread across
machines (e.g., via Slurm) that do not share access to the file system
on which [`tempdir()`](https://rdrr.io/r/base/tempfile.html) resides.

## Usage

``` r
set_tempdir_base(path)
```

## Arguments

- path:

  The name of an existing directory.

## Value

The absolute path (invisibly) to the subdirectory under `path` that
`mrgsim.ds` will use as its temporary directory.

## Details

Although the specified directory may reside anywhere, it should be
treated as a temporary directory. Use
[`save_ds()`](https://metrumresearchgroup.github.io/mrgsim.ds/reference/save_ds.md)
or
[`move_ds()`](https://metrumresearchgroup.github.io/mrgsim.ds/reference/move_ds.md)
to move the files to more permanent locations.

`mrgsim.ds` may delete the backing parquet files in its temporary
directory (see
[`gc_ds()`](https://metrumresearchgroup.github.io/mrgsim.ds/reference/gc_ds.md)),
but it does not delete `path` or the temporary directory that it creates
within it. The caller is expected to manage this temporary directory,
including its removal.

This function aborts if it is called after any `mrgsim.ds` functionality
that relies on the temporary directory.

## See also

[`list_temp()`](https://metrumresearchgroup.github.io/mrgsim.ds/reference/list_temp.md)
