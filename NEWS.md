# mrgsim.ds 0.2.0

## New features

- Simulated output can be written to a directory other than `tempdir()`: pass
  `dir` to `mread_ds()`, `mcode_ds()`, `modlib_ds()`, `house_ds()`,
  `mread_cache_ds()`, or `save_process_info()`, or set
  `options(mrgsim.ds.dir = )` as a session default. This is intended for
  parallel simulation, where worker processes generally cannot see `tempdir()`
  from the R process which loaded the model.

- New `set_ds_dir()` re-targets the output directory on a model object which
  was already loaded and `get_ds_dir()` reports where output will be written.

- `list_temp()` and `purge_temp()` gain a `dir` argument, which defaults to
  `getOption("mrgsim.ds.dir")`, falling back to `tempdir()`. `purge_temp()`
  also gains `force`, which is required to delete files in a directory outside
  of `tempdir()`.

## Changes

- Automatic gc adjustment now keys on the output directory where the files were
  written rather than on `tempdir()`: output written to a custom directory
  still gets `gc = TRUE`, and `move_ds()` turns gc off when files leave that
  directory (back on when they return).

- `save_ds()` now warns when the backing files it just saved are still subject
  to garbage collection, rather than when they are in `tempdir()`.

- `read_ds()` sets the restored object's output directory to the directory
  holding the `.rds` file.

- Model objects are now stamped with `mrgsim.ds.output_dir` in place of
  `mrgsim.ds.mread_tempdir`; models stamped by earlier versions continue to
  work.

# mrgsim.ds 0.1.1

- Minor fixes: corrected the package description in `DESCRIPTION` (#11) and  
  removed the r-universe links from the README (#13).

## Bugs fixed

- Fixed a bug where garbage collection of an `mrgsimsds` object left stale
  entries in the internal `addresses` map; `clean_up_ds()` now disowns the
  files it removes (#10).

# mrgsim.ds 0.1.0

- Initial release


