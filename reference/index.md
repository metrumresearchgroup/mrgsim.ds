# Package index

## Landing page

- [`mrgsim.ds-package`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim.ds.md)
  [`mrgsim.ds`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim.ds.md)
  : mrgsim.ds: 'Apache' 'Arrow' Dataset-Backed Simulation Outputs for
  'mrgsolve'

## Read or load models

Functions to read models configured for use with
[`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md).

- [`mread_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md)
  [`mcode_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md)
  [`modlib_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md)
  [`house_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md)
  [`mread_cache_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md)
  : Load an mrgsolve model for Arrow-backed simulation

## Generate Apache Arrow dataset-backed simulation outputs

Simulate and write output to disk.

- [`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md)
  : Simulate from a model object, returning an 'Apache' 'Arrow'-backed
  output object
- [`as_mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/as_mrgsim_ds.md)
  : Coerce an mrgsims object to 'Apache' 'Arrow'-backed mrgsimsds object

## S3 Methods

Work with
[`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md)
output.

- [`dim(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-methods.md)
  [`head(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-methods.md)
  [`tail(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-methods.md)
  [`names(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-methods.md)
  [`plot(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-methods.md)
  : Interact with mrgsimsds objects
- [`print(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/print.mrgsimsds.md)
  : Print an mrgsimsds object
- [`group_by(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-verbs.md)
  [`select(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-verbs.md)
  [`mutate(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-verbs.md)
  [`filter(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-verbs.md)
  [`arrange(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-verbs.md)
  [`rename(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-verbs.md)
  [`summarise(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-verbs.md)
  [`distinct(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-verbs.md)
  [`relocate(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-verbs.md)
  [`count(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-verbs.md)
  [`pull(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-verbs.md)
  : dplyr verbs for mrgsimsds objects

## Move, rename, or save outputs

- [`move_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md)
  [`rename_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md)
  [`combine_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md)
  : Move, rename, combine files in mrgsimsds objects
- [`save_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/save_ds.md)
  [`read_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/save_ds.md)
  : Save and restore an mrgsimsds object
- [`write_parquet_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/write_parquet_ds.md)
  [`write_dataset_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/write_parquet_ds.md)
  : Write simulations to a parquet file or partitioned dataset
- [`files_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/files_ds.md)
  : Get names of backing files
- [`current_location()`](https://kylebaron.github.io/mrgsim.ds/reference/current_location.md)
  : Get the current location of mrgsimsds object files

## Manage or query ownership

This applies to ownership parquet files holding simulation outputs for
the duration of the working R session.

- [`ownership()`](https://kylebaron.github.io/mrgsim.ds/reference/ownership.md)
  [`list_ownership()`](https://kylebaron.github.io/mrgsim.ds/reference/ownership.md)
  [`check_ownership()`](https://kylebaron.github.io/mrgsim.ds/reference/ownership.md)
  [`disown()`](https://kylebaron.github.io/mrgsim.ds/reference/ownership.md)
  [`take_ownership()`](https://kylebaron.github.io/mrgsim.ds/reference/ownership.md)
  : Ownership of simulation files
- [`copy_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/copy_ds.md)
  : Copy an mrgsimsds object

## Work with lists of mrgsimsds objects

Commonly needed after batch simulation in parallel

- [`reduce_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/reduce_ds.md)
  : Reduce a list of mrgsimsds objects into a single object
- [`refresh_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/refresh_ds.md)
  : Refresh 'Arrow' dataset pointers
- [`gc_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/gc_ds.md)
  : Set garbage collection behavior for mrgsimsds objects
- [`prune_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/prune_ds.md)
  : Prune a list of mrgsimsds objects

## Manage simulation outputs in `tempdir()`

- [`list_temp()`](https://kylebaron.github.io/mrgsim.ds/reference/list_temp.md)
  [`purge_temp()`](https://kylebaron.github.io/mrgsim.ds/reference/list_temp.md)
  : Manage simulated outputs in the per-session temporary directory

## Utility functions

- [`save_process_info()`](https://kylebaron.github.io/mrgsim.ds/reference/save_process_info.md)
  : Save information about the R process that loaded a model
- [`is_mrgsimsds()`](https://kylebaron.github.io/mrgsim.ds/reference/is_mrgsimsds.md)
  : Check if object inherits mrgsimsds

## Coerce output to an R object

- [`as_tibble(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/as_tibble.mrgsimsds.md)
  [`collect(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/as_tibble.mrgsimsds.md)
  [`as.data.frame(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/as_tibble.mrgsimsds.md)
  : Coerce an mrgsimsds object to a tbl
- [`as_arrow_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/as_arrow_ds.md)
  : Coerce an mrgsimsds object to an arrow data set
- [`as_arrow_table(`*`<mrgsimsds>`*`)`](https://kylebaron.github.io/mrgsim.ds/reference/as_arrow_table.mrgsimsds.md)
  : Coerce an mrgsimsds object to an arrow table
- [`as_duckdb_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/as_duckdb_ds.md)
  : Coerce an mrgsimsds object to a DuckDB table
