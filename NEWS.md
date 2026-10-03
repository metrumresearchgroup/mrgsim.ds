# mrgsim.ds 0.2.0

## New features

- Simulated output can be written to a directory other than `tempdir()`: pass
  `ds_dir` to `mread_ds()`, `mcode_ds()`, `modlib_ds()`, `house_ds()`,
  `mread_cache_ds()`, or `save_process_info()`, or set
  `options(mrgsim.ds.dir = )` as a session default. This is intended for
  parallel simulation on a grid, where worker processes may not be able to 
  see `tempdir()` from the R process which loaded the model.

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

- `save_ds()` now turns gc off for the saved object unless gc was locked with
  `gc_ds()`. It warns when the saved files are not in a safe place for 
  long-term storage: gc is locked to `TRUE`, the files are under `tempdir()`,
  or the files are in the simulation output directory.

- Objects saved with `save_ds()` or restored with `read_ds()` are detached from
  the simulation output directory, so automatic gc can no longer turn back on
  for them (e.g., after `move_ds()` or `reduce_ds()`). Re-saving a restored
  object does not warn.

- `mrgsim_ds()` and `as_mrgsim_ds()` now error when the output directory does
  not exist in the R process running the simulation (e.g., a worker on another
  node that can't see the directory).

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


