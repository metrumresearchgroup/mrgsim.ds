
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
.     ID time       CL     IPRED
. 1:   1  0.0 1.170849 0.0000000
. 2:   1  0.0 1.170849 0.0000000
. 3:   1  0.5 1.170849 0.9304048
. 4:   1  1.0 1.170849 1.6292029
. 5:   1  1.5 1.170849 2.1489780
. 6:   1  2.0 1.170849 2.5304864
. 7:   1  2.5 1.170849 2.8053143
. 8:   1  3.0 1.170849 2.9979387
```

## Very lightweight simulation output object

The output object doesn’t actually carry these 1.4M rows of simulated
data. Rather it stores a pointer to the data in parquet files on your
disk.

``` r
basename(out$files)
. [1] "mrgsims-ds-486110cf3d3.parquet"
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
. 1     1   0    1.17 0    
. 2     1   0    1.17 0    
. 3     1   0.5  1.17 0.930
. 4     1   1    1.17 1.63 
. 5     1   1.5  1.17 2.15 
. 6     1   2    1.17 2.53

tail(out)
. # A tibble: 6 × 4
.      ID  time    CL IPRED
.   <dbl> <dbl> <dbl> <dbl>
. 1  3000  238. 0.877 0.384
. 2  3000  238  0.877 0.379
. 3  3000  238. 0.877 0.375
. 4  3000  239  0.877 0.370
. 5  3000  240. 0.877 0.365
. 6  3000  240  0.877 0.361

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
.  1     1   0    1.17 0    
.  2     1   0    1.17 0    
.  3     1   0.5  1.17 0.930
.  4     1   1    1.17 1.63 
.  5     1   1.5  1.17 2.15 
.  6     1   2    1.17 2.53 
.  7     1   2.5  1.17 2.81 
.  8     1   3    1.17 3.00 
.  9     1   3.5  1.17 3.13 
. 10     1   4    1.17 3.21 
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
. # Database: DuckDB 1.5.1 [kyleb@Darwin 24.6.0:R 4.5.3/:memory:]
.       ID  time    CL IPRED
.    <dbl> <dbl> <dbl> <dbl>
.  1     1   0    1.17 0    
.  2     1   0    1.17 0    
.  3     1   0.5  1.17 0.930
.  4     1   1    1.17 1.63 
.  5     1   1.5  1.17 2.15 
.  6     1   2    1.17 2.53 
.  7     1   2.5  1.17 2.81 
.  8     1   3    1.17 3.00 
.  9     1   3.5  1.17 3.13 
. 10     1   4    1.17 3.21 
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
.  2   0.5  1.09  3000
.  3   1    1.79  3000
.  4   1.5  2.25  3000
.  5   2    2.56  3000
.  6   2.5  2.78  3000
.  7   3    2.92  3000
.  8   3.5  3.02  3000
.  9   4    3.08  3000
. 10   4.5  3.12  3000
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
.     ID time       CL    IPRED
. 1:   1  0.0 0.672067 0.000000
. 2:   1  0.0 0.672067 0.000000
. 3:   1  0.5 0.672067 1.129249
. 4:   1  1.0 0.672067 2.018886
. 5:   1  1.5 0.672067 2.715466
. 6:   1  2.0 0.672067 3.256577
. 7:   1  2.5 0.672067 3.672563
. 8:   1  3.0 0.672067 3.987920
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
. - mrgsims-ds-486110cf3d3.parquet
. - mrgsims-ds-4cd40dc5bf2.parquet
.    ...
. - mrgsims-ds-4d149917672.parquet
. - mrgsims-ds-4d17ebf6d10.parquet
```

This directory is eventually removed when the R session ends. Tools are
provided to manage the space.

``` r
retain_temp(out2)
. Discarding 1 files.

list_temp()
. 10 files [131.8 Mb]
. - mrgsims-ds-4cd40dc5bf2.parquet
. - mrgsims-ds-4cd76cdcb45.parquet
.    ...
. - mrgsims-ds-4d149917672.parquet
. - mrgsims-ds-4d17ebf6d10.parquet
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
. - mrgsims-ds-out1-1.parquet
. - mrgsims-ds-out2-01.parquet
.    ...
. - mrgsims-ds-out2-10.parquet
. - mrgsims-ds-out3-1.parquet
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
. Ncells  2275239 121.6    3813578 203.7         NA  3813578 203.7
. Vcells 15673798 119.6   26745405 204.1      16384 22220811 169.6

list_temp()
. 2 files [26.4 Mb]
. - mrgsims-ds-out1-1.parquet
. - mrgsims-ds-out3-1.parquet
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
.     ID TIME       CL     IPRED
. 1:   1  0.0 1.098624 0.0000000
. 2:   1  0.0 1.098624 0.0000000
. 3:   1  0.5 1.098624 0.2922486
. 4:   1  1.0 1.098624 0.5561621
. 5:   1  1.5 1.098624 0.7940186
. 6:   1  2.0 1.098624 1.0079207
. 7:   1  2.5 1.098624 1.1998089
. 8:   1  3.0 1.098624 1.3714743
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
.     ID TIME       CL     IPRED
. 1:   1  0.0 1.098624 0.0000000
. 2:   1  0.0 1.098624 0.0000000
. 3:   1  0.5 1.098624 0.2922486
. 4:   1  1.0 1.098624 0.5561621
. 5:   1  1.5 1.098624 0.7940186
. 6:   1  2.0 1.098624 1.0079207
. 7:   1  2.5 1.098624 1.1998089
. 8:   1  3.0 1.098624 1.3714743
```

Now we have all three files collected in a single object that we can
work with

``` r
plot(out, IPRED ~ time, nid = 5)
```

<img src="man/figures/README-parallel_output-1.png" alt="" width="80%" style="display: block; margin: auto;" />

## Save outputs

You can save the simulation output object for use later

``` r
save_ds(out, "inst/readme_temp/sims.rds")
. ℹ files are now located in inst/readme_temp; gc is off.
```

This saves the object in an `.rds` file located in the `inst` directory.
Importantly, the backing files are also relocated to the `.rds` location
so they can be found later on.

On read, the object is fully functional again with ownership transferred
to the new object.

``` r
out2 <- read_ds("inst/readme_temp/sims.rds")

out2
. Model: popex
. Dim  : 2,628 x 4
. Files: 3 [31.4 Kb]
. Owner: yes (no gc)
.     ID TIME       CL     IPRED
. 1:   1  0.0 1.098624 0.0000000
. 2:   1  0.0 1.098624 0.0000000
. 3:   1  0.5 1.098624 0.2922486
. 4:   1  1.0 1.098624 0.5561621
. 5:   1  1.5 1.098624 0.7940186
. 6:   1  2.0 1.098624 1.0079207
. 7:   1  2.5 1.098624 1.1998089
. 8:   1  3.0 1.098624 1.3714743
```

``` r
check_ownership(out)
. [1] FALSE
check_ownership(out2)
. [1] TRUE
```

## Details

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
