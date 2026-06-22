# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## What This Package Does

**mrgsim.ds** is an Apache Arrow-backed simulation output package for
mrgsolve. It stores simulation outputs as Parquet files on disk (in
[`tempdir()`](https://rdrr.io/r/base/tempfile.html)) rather than
in-memory data frames, dramatically reducing memory footprint for large
pharmacokinetic/pharmacodynamic simulations while enabling
high-performance summarization via dplyr verbs.

## Common Commands

All via `make` from the repo root:

``` bash
make doc        # Regenerate roxygen documentation (run after editing @-tags)
make test       # Run testthat tests
make check      # R CMD check (skips vignettes)
make build      # Build package tarball
make install    # Install from tarball
make readme     # Render README.Rmd → README.md
```

Run a single test file from R:

``` r

testthat::test_file("tests/testthat/test-own.R")
```

## Architecture

### Core Object: `mrgsimsds` (an R environment)

The central object is not a data frame — it’s a lightweight environment
with fields: - `$ds` — Arrow Dataset (lazy pointer to parquet files on
disk) - `$files` — paths to parquet files - `$hash` — xxh3_64 hashes of
those files (used by the ownership system) - `$pid` — process ID where
the object was created - `$gc` — whether files are auto-deleted on GC
finalization - `$mod` — the mrgsolve model object that produced the
simulation

### Ownership System (`R/own.R`)

Two package-level hash environments (`hash2addr`, `hash2file`) map file
hashes to object memory addresses. Only the “owner” of a file can move
or delete it. Ownership transfers via
[`take_ownership()`](https://kylebaron.github.io/mrgsim.ds/reference/ownership.md)
/
[`disown()`](https://kylebaron.github.io/mrgsim.ds/reference/ownership.md).
Files auto-delete on GC only if owned. This prevents accidental deletion
when objects are copied or passed between contexts.

### Process Safety (`R/refresh.R`, `R/utils.R`)

Objects track `$pid` (creation process). Arrow Dataset pointers become
invalid across forked processes.
[`refresh_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/refresh_ds.md)
rebuilds the pointer from the file paths. The GC finalizer only runs in
the original process to avoid double-deletes during parallel
simulations.

### Key Source Files

| File | Responsibility |
|----|----|
| `R/mrgsim-ds.R` | [`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md), [`as_mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/as_mrgsim_ds.md), core S3 methods |
| `R/own.R` | Ownership system: claim, transfer, disown |
| `R/files.R` | [`move_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md), [`rename_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md), [`combine_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md), [`save_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/save_ds.md), [`read_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/save_ds.md), [`write_parquet_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/write_parquet_ds.md), [`write_dataset_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/write_parquet_ds.md) |
| `R/wrapper.R` | [`mread_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md) and friends — mrgsolve model loading (stamps model with [`save_process_info()`](https://kylebaron.github.io/mrgsim.ds/reference/save_process_info.md), required before [`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md)) |
| `R/collect.R` | Coercion to tibble, Arrow table, DuckDB |
| `R/verbs.R` | dplyr S3 methods (filter, mutate, summarise, etc.) |
| `R/reduce.R` | [`reduce_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/reduce_ds.md) — combines a list of outputs |
| `R/refresh.R` | [`refresh_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/refresh_ds.md) — rebuild Arrow pointer post-fork |
| `R/temp.R` | [`list_temp()`](https://kylebaron.github.io/mrgsim.ds/reference/list_temp.md), [`purge_temp()`](https://kylebaron.github.io/mrgsim.ds/reference/list_temp.md) |
| `R/gc.R` | [`gc_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/gc_ds.md) — toggle GC/auto-delete and notify flags |
| `R/prune.R` | [`prune_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/prune_ds.md) — filter a list to only mrgsimsds objects |
| `R/simlist.R` | Internal helpers for working with lists of mrgsimsds objects |

### Package-level State (`R/AAA.R`)

A `.global` environment holds package-wide constants and state: -
`file.prefix` — `"mrgsims-ds-"` (prefix for all parquet files) -
`file.re` — regex to identify package-managed files - `nullptr` —
sentinel `externalptr` used to detect invalidated Arrow pointers -
`trashcan` — a subdirectory of
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) used as staging area
before file deletion

Option `mrgsim.ds.show.gc` (set via
[`options()`](https://rdrr.io/r/base/options.html)) prints messages when
GC removes files — useful for debugging ownership/cleanup issues.

### File Naming Convention

Parquet files are written to
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) with the pattern:

    mrgsims-ds-{id}-{index}.parquet

e.g., `mrgsims-ds-out2-0001.parquet`
