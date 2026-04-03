
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mrgsim.ds

<!-- badges: start -->

[![R-universe
version](https://kylebaron.r-universe.dev/mrgsim.ds/badges/version)](https://kylebaron.r-universe.dev/mrgsim.ds)
[![r-universe
status](https://kylebaron.r-universe.dev/mrgsim.ds/badges/checks)](https://kylebaron.r-universe.dev/mrgsim.ds)
[![R-CMD-check](https://github.com/kylebaron/mrgsim.ds/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/kylebaron/mrgsim.ds/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`mrgsim.ds` provides an [Apache
Arrow](https://arrow.apache.org/docs/r/)-backed simulation output object
for [mrgsolve](https://mrgsolve.org), greatly reducing the memory
footprint of large simulations and providing a high-performance pipeline
for summarizing huge simulation outputs. The arrow-based simulation
output objects in R claim ownership of their files on disk. Those files
are automatically removed when the owning object goes out of scope and
becomes subject to the R garbage collector. While “anonymous”,
parquet-formatted files hold the data in `tempdir()` as you are working
in R, functions are provided to move this data to more permanent
locations for later use.

## Installation

You can install the development version of `mrgsim.ds` from
[r-universe](https://kylebaron.r-universe.dev/mrgsim.ds) with:

``` r
# Install 'mrgsim.ds' in R:
install.packages('mrgsim.ds', repos = c('https://kylebaron.r-universe.dev', 'https://cloud.r-project.org'))
```

## Example

We will illustrate `mrgsim.ds` by doing a simulation.

``` r
library(mrgsim.ds)
library(dplyr)

mod <- modlib_ds("popex", end = 240, outvars = "IPRED,CL")

data <- expand.ev(amt = 100, ii = 24, total = 6, ID = 1:3000)
```

`mrgsim.ds` provides a new `mrgsim()` variant - `mrgsim_ds()`. The name
implies we are tapping into Apache Arrow
[Dataset](https://arrow.apache.org/docs/r/reference/Dataset.html)
functionality. The simulation below carries `1,446,000` rows.

``` r
out <- mrgsim_ds(mod, data)

out
. Model: popex
. Dim  : 1.4M x 4
. Files: 1 [13.2 Mb]
. Owner: yes (gc)
.     ID time        CL     IPRED
. 1:   1  0.0 0.9648573 0.0000000
. 2:   1  0.0 0.9648573 0.0000000
. 3:   1  0.5 0.9648573 0.5279033
. 4:   1  1.0 0.9648573 0.9509657
. 5:   1  1.5 0.9648573 1.2886638
. 6:   1  2.0 0.9648573 1.5568730
. 7:   1  2.5 0.9648573 1.7685336
. 8:   1  3.0 0.9648573 1.9341928
```

## Very lightweight simulation output object

The output object doesn’t actually carry these 1.4M rows of simulated
data. Rather it stores a pointer to the data in parquet files on your
disk.

``` r
basename(out$files)
. [1] "mrgsims-ds-136b57a594b2d.parquet"
```

This means there is almost nothing inside the object itself

``` r
lobstr:::obj_size(out)
. 293.65 kB

dim(out)
. [1] 1446000       4
```

What if we did the same simulation with regular `mrgsim()`?

``` r
x <- mrgsim(mod, data)

lobstr::obj_size(x)
. 46.30 MB

dim(x)
. [1] 1446000       4
```

The `mrgsim.ds` object is very light weight despite tracking the same
data.

## Handles like regular mrgsim output

But, we can do a lot of the typical things we would with any `mrgsim()`
output object.

``` r
plot(out, nid = 12)
```

<img src="man/figures/README-plot_head_tail_dim-1.png" alt="" width="80%" style="display: block; margin: auto;" />

``` r

head(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1     1   0   0.965 0    
. 2     1   0   0.965 0    
. 3     1   0.5 0.965 0.528
. 4     1   1   0.965 0.951
. 5     1   1.5 0.965 1.29 
. 6     1   2   0.965 1.56

tail(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1  3000  238. 0.550 0.191
. 2  3000  238  0.550 0.188
. 3  3000  238. 0.550 0.184
. 4  3000  239  0.550 0.181
. 5  3000  240. 0.550 0.178
. 6  3000  240  0.550 0.175

dim(out)
. [1] 1446000       4
```

This includes coercing to different types of objects. We can get the
usual R data frames

``` r
as_tibble(out)
. # A tibble: 1,446,000 × 4
.       ID  time    CL IPRED
.    <dbl> <dbl> <dbl> <dbl>
.  1     1   0   0.965 0    
.  2     1   0   0.965 0    
.  3     1   0.5 0.965 0.528
.  4     1   1   0.965 0.951
.  5     1   1.5 0.965 1.29 
.  6     1   2   0.965 1.56 
.  7     1   2.5 0.965 1.77 
.  8     1   3   0.965 1.93 
.  9     1   3.5 0.965 2.06 
. 10     1   4   0.965 2.16 
. # ℹ 1,445,990 more rows
```

Or stay in the arrow ecosystem

``` r
as_arrow_ds(out)
. FileSystemDataset with 1 Parquet file
. 4 columns
. ID: double
. time: double
. CL: double
. IPRED: double
. 
. See $metadata for additional Schema metadata
```

Or try your hand at duckdb

``` r
as_duckdb_ds(out)
. # Source:   table<arrow_001> [?? x 4]
. # Database: DuckDB 1.4.4 [kyleb@Darwin 24.6.0:R 4.5.3/:memory:]
.       ID  time    CL IPRED
.    <dbl> <dbl> <dbl> <dbl>
.  1     1   0   0.965 0    
.  2     1   0   0.965 0    
.  3     1   0.5 0.965 0.528
.  4     1   1   0.965 0.951
.  5     1   1.5 0.965 1.29 
.  6     1   2   0.965 1.56 
.  7     1   2.5 0.965 1.77 
.  8     1   3   0.965 1.93 
.  9     1   3.5 0.965 2.06 
. 10     1   4   0.965 2.16 
. # ℹ more rows
```

## Tidyverse-friendly

We’ve integrated into the `dplyr` ecosystem as well, allowing you to
`filter()`, `group_by()`, `mutate()`, `select()`, `summarise()`,
`rename()`, or `arrange()` your way directly into a pipeline to
summarize your simulations using the power of Apache Arrow.

``` r
dd <- 
  out %>% 
  group_by(time) %>% 
  summarise(Mean = mean(IPRED, na.rm = TRUE), n = n()) %>% 
  arrange(time)

dd
. FileSystemDataset (query)
. time: double
. Mean: double
. n: int64
. 
. * Sorted by time [asc]
. See $.data for the source Arrow object
```

``` r
collect(dd)
. # A tibble: 481 × 3
.     time  Mean     n
.    <dbl> <dbl> <int>
.  1   0    0     6000
.  2   0.5  1.08  3000
.  3   1    1.77  3000
.  4   1.5  2.23  3000
.  5   2    2.55  3000
.  6   2.5  2.77  3000
.  7   3    2.91  3000
.  8   3.5  3.01  3000
.  9   4    3.08  3000
. 10   4.5  3.11  3000
. # ℹ 471 more rows
```

## Good for large simulations

This workflow is particularly useful when running replicate simulations
in parallel, with large outputs

``` r
library(future.apply, quietly = TRUE)

plan(multisession, workers = 5L)

out2 <- future_lapply(1:10, \(x) { mrgsim_ds(mod, data) }, future.seed = TRUE)

out2 <- reduce_ds(out2)
```

Now there are 10x the number of rows (14.5M), but little change in
object size.

``` r
out2
. Model: popex
. Dim  : 14.5M x 4
. Files: 10 [131.8 Mb]
. Owner: yes (gc)
.     ID time        CL     IPRED
. 1:   1  0.0 0.4087804 0.0000000
. 2:   1  0.0 0.4087804 0.0000000
. 3:   1  0.5 0.4087804 0.1660721
. 4:   1  1.0 0.4087804 0.3228486
. 5:   1  1.5 0.4087804 0.4707932
. 6:   1  2.0 0.4087804 0.6103471
. 7:   1  2.5 0.4087804 0.7419299
. 8:   1  3.0 0.4087804 0.8659402
```

``` r
lobstr::obj_size(out2)
. 296.81 kB
```

## Files on disk are automagically managed

All `arrow` files are stored in the `tempdir()` in parquet format

``` r
list_temp()
. 11 files [145 Mb]
. - mrgsims-ds-136b57a594b2d.parquet
. - mrgsims-ds-136f93697cf0f.parquet
.    ...
. - mrgsims-ds-136fd1998f902.parquet
. - mrgsims-ds-136fda03ff6f.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [131.8 Mb]
. - mrgsims-ds-136f93697cf0f.parquet
. - mrgsims-ds-136f94c391131.parquet
.    ...
. - mrgsims-ds-136fd1998f902.parquet
. - mrgsims-ds-136fda03ff6f.parquet
```

We also put a finalizer on each object so that, when it goes out of
scope, the files are automatically cleaned up.

First, run a bunch of simulations.

``` r
plan(multisession, workers = 5L)

out1 <- mrgsim_ds(mod, data)
rename_ds(out1, "out1")

out2 <- future_lapply(1:10, \(x) { mrgsim_ds(mod, data) }, future.seed = TRUE)

out2 <- reduce_ds(out2)
rename_ds(out2, "out2")

out3 <- mrgsim_ds(mod, data) 
rename_ds(out3, "out3")
```

There are 12 files holding simulation outputs.

``` r
list_temp()
. 12 files [158.2 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out2-0001.parquet
.    ...
. - mrgsims-ds-out2-0010.parquet
. - mrgsims-ds-out3-0001.parquet
```

Now, remove one of the objects containing 10 files.

``` r
rm(out2)
```

As soon as the garbage collector is called, the leftover files are
cleaned up.

``` r
gc()
.            used  (Mb) gc trigger  (Mb) limit (Mb) max used  (Mb)
. Ncells  2308276 123.3    3828742 204.5         NA  3828742 204.5
. Vcells 15723850 120.0   26766118 204.3      16384 22237732 169.7

list_temp()
. 2 files [26.4 Mb]
. - mrgsims-ds-out1-0001.parquet
. - mrgsims-ds-out3-0001.parquet
```

### Ownership

This setup is only possible if one object owns the files on disk and
`mrgsim.ds` tracks this.

``` r
ownership()
. > Objects: 4 | Files: 13 | Size: 26.4 Mb
```

If I make a copy of a simulation object, the old object no longer owns
the files.

``` r
out4 <- copy_ds(out1, own = TRUE)

check_ownership(out1)
. [1] FALSE

check_ownership(out4)
. [1] TRUE
```

I can always take ownership back.

``` r
take_ownership(out1)

check_ownership(out1)
. [1] TRUE

check_ownership(out4)
. [1] FALSE
```

## Simulation in parallel

Some special handling is required when simulations are actually run in
an R session different from the one where the model was loaded and where
simulation outputs will be processed. One key example of this situation
is simulation in parallel, especially when worker nodes are different R
processes.

For example, we can run this simulation in parallel.

``` r
library(mirai)

mod <- modlib_ds("popex", end = 72)
. Loading model from cache.

data <- evd_expand(amt = 100, ID = 1:6)

daemons(3)

out <- mirai_map(
  1:3, 
  \(x, mod, data) { mrgsim.ds::mrgsim_ds(mod, data) },
  .args = list(mod = mod, data = data)
)[]

daemons(0)
```

First, notice that we used `modlib_ds()` rather than
`mrgsolve::modlib()`. The resulting object has the important information
tucked away to safely simulate in parallel.

Now look at the output. When we print the object to the console, you
will see that `mrgsim.ds` recognizes that the object was created in a
different R process and updates `pid` as well as the pointer to the
`arrow` data set:

``` r
out[[1]]
. Model: popex
. Dim  : 876 x 4
. Files: 1 [10.5 Kb]
. Owner: no
.     ID TIME        CL     IPRED
. 1:   1  0.0 0.5554277 0.0000000
. 2:   1  0.0 0.5554277 0.0000000
. 3:   1  0.5 0.5554277 0.8066047
. 4:   1  1.0 0.5554277 1.4129891
. 5:   1  1.5 0.5554277 1.8670459
. 6:   1  2.0 0.5554277 2.2052282
. 7:   1  2.5 0.5554277 2.4552817
. 8:   1  3.0 0.5554277 2.6383245
. [mrgsim.ds] pointer and source pid refreshed.
```

I refer to this as “refreshing” the output: relocate back on the parent
R process and re-create the pointer to the data on disk.

You can refresh a list of simulations like this

``` r
out <- refresh_ds(out)
```

This will get you relocated back on the parent R process. Better yet,
you should call `reduce_ds()`

``` r
out <- reduce_ds(out)
```

This refreshes the simulation output objects *and* collects them into a
single object

``` r
out
. Model: popex
. Dim  : 2,628 x 4
. Files: 3 [31.4 Kb]
. Owner: yes (gc)
.     ID TIME        CL     IPRED
. 1:   1  0.0 0.5554277 0.0000000
. 2:   1  0.0 0.5554277 0.0000000
. 3:   1  0.5 0.5554277 0.8066047
. 4:   1  1.0 0.5554277 1.4129891
. 5:   1  1.5 0.5554277 1.8670459
. 6:   1  2.0 0.5554277 2.2052282
. 7:   1  2.5 0.5554277 2.4552817
. 8:   1  3.0 0.5554277 2.6383245
```

Now we have all three files collected in a single object that we can
work with

``` r
plot(out, IPRED ~ time, nid = 5)
```

<img src="man/figures/README-parallel_output-1.png" alt="" width="80%" style="display: block; margin: auto;" />

### Details

`mrgsim.ds` tracks the `tempdir()` location and the process ID (via
`Sys.getpid()`) of the R process where the model was loaded. When
simulation outputs are saved to file, the save location is always
`tempdir()` from that parent R process. When simulating in parallel,
this will likely be *different* than what a call to `tempdir()` says on
the worker node.

At the time simulations are saved, the current R process id (`pid`) is
saved to the simulation output object. In the parallel simulation case,
this will be different than the `pid` from the parent R process, saved
in the model object. The finalizer function for a simulation object
which removes output files from disk when the object goes out of scope
is only run when the finalizer is called from the parent R process as
determined by `Sys.getpid()`.

## If this is so great, why not make it the default for mrgsolve?

There is a cost to all of this. For small to mid-size simulations, you
might see a small slowdown with `mrgsim_ds()`; it definitely won’t be
faster than `mrgsim()` … even with the super-quick arrow ecosystem. This
workflow is really for large simulation volumes where you are happy to
pay the cost of writing outputs to file and then streaming them back in
to summarize.
