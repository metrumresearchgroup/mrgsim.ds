# dplyr verbs for mrgsimsds objects

Standard dplyr verbs dispatched on an mrgsimsds object. Each verb
extracts the underlying Arrow Dataset and forwards all arguments to the
corresponding dplyr generic, returning a lazy Arrow query that can be
materialized with
[`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html).

## Usage

``` r
# S3 method for class 'mrgsimsds'
group_by(.data, ..., .add = FALSE, .drop = TRUE)

# S3 method for class 'mrgsimsds'
select(.data, ...)

# S3 method for class 'mrgsimsds'
mutate(.data, ...)

# S3 method for class 'mrgsimsds'
filter(.data, ..., .preserve = FALSE)

# S3 method for class 'mrgsimsds'
arrange(.data, ..., .by_group = FALSE)

# S3 method for class 'mrgsimsds'
rename(.data, ...)

# S3 method for class 'mrgsimsds'
summarise(.data, ..., .groups = NULL)

# S3 method for class 'mrgsimsds'
distinct(.data, ..., .keep_all = FALSE)

# S3 method for class 'mrgsimsds'
relocate(.data, ..., .before = NULL, .after = NULL)

# S3 method for class 'mrgsimsds'
count(x, ..., wt = NULL, sort = FALSE, name = NULL)

# S3 method for class 'mrgsimsds'
pull(.data, var = -1, name = NULL, as_vector = TRUE, ...)
```

## Arguments

- .data, x:

  an mrgsimsds object.

- ...:

  passed to the corresponding dplyr generic.

- .add, .drop:

  passed to
  [`dplyr::group_by()`](https://dplyr.tidyverse.org/reference/group_by.html).

- .preserve:

  passed to
  [`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html).

- .by_group:

  passed to
  [`dplyr::arrange()`](https://dplyr.tidyverse.org/reference/arrange.html).

- .groups:

  passed to
  [`dplyr::summarise()`](https://dplyr.tidyverse.org/reference/summarise.html).

- .keep_all:

  passed to
  [`dplyr::distinct()`](https://dplyr.tidyverse.org/reference/distinct.html).

- .before, .after:

  passed to
  [`dplyr::relocate()`](https://dplyr.tidyverse.org/reference/relocate.html).

- wt, sort:

  passed to
  [`dplyr::count()`](https://dplyr.tidyverse.org/reference/count.html).

- name:

  passed to
  [`dplyr::pull()`](https://dplyr.tidyverse.org/reference/pull.html).

- var:

  passed to
  [`dplyr::pull()`](https://dplyr.tidyverse.org/reference/pull.html).

- as_vector:

  passed to
  [`dplyr::pull()`](https://dplyr.tidyverse.org/reference/pull.html).

## Value

A lazy Arrow query object. Use
[`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html)
to materialize the result into a tibble.
[`pull()`](https://dplyr.tidyverse.org/reference/pull.html) is an
exception — it collects immediately and returns a vector.

## Examples

``` r
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union

mod <- house_ds(end = 24)

data <- evd_expand(amt = c(100, 300), ID = 1:10)

out <- mrgsim_ds(mod, data)

out |> filter(TIME > 0) |> select(ID, TIME, CP) |> collect()
#> # A tibble: 1,920 × 3
#>       ID  TIME    CP
#>    <dbl> <dbl> <dbl>
#>  1     1  0.25  1.29
#>  2     1  0.5   2.23
#>  3     1  0.75  2.90
#>  4     1  1     3.39
#>  5     1  1.25  3.74
#>  6     1  1.5   3.98
#>  7     1  1.75  4.14
#>  8     1  2     4.25
#>  9     1  2.25  4.31
#> 10     1  2.5   4.34
#> # ℹ 1,910 more rows

out |> group_by(ID) |> summarise(auc = sum(CP)) |> collect()
#> # A tibble: 20 × 2
#>       ID   auc
#>    <dbl> <dbl>
#>  1     1  275.
#>  2     2  825.
#>  3     3  275.
#>  4     4  825.
#>  5     5  275.
#>  6     6  825.
#>  7     7  275.
#>  8     8  825.
#>  9     9  275.
#> 10    10  825.
#> 11    11  275.
#> 12    12  825.
#> 13    13  275.
#> 14    14  825.
#> 15    15  275.
#> 16    16  825.
#> 17    17  275.
#> 18    18  825.
#> 19    19  275.
#> 20    20  825.

out |> mutate(WEEK = TIME / 168) |> collect()
#> # A tibble: 1,960 × 8
#>       ID  TIME    GUT  CENT  RESP    DV    CP    WEEK
#>    <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl>
#>  1     1  0      0      0    50    0     0    0      
#>  2     1  0    100      0    50    0     0    0      
#>  3     1  0.25  74.1   25.7  48.7  1.29  1.29 0.00149
#>  4     1  0.5   54.9   44.5  46.2  2.23  2.23 0.00298
#>  5     1  0.75  40.7   58.1  43.6  2.90  2.90 0.00446
#>  6     1  1     30.1   67.8  41.4  3.39  3.39 0.00595
#>  7     1  1.25  22.3   74.7  39.6  3.74  3.74 0.00744
#>  8     1  1.5   16.5   79.6  38.2  3.98  3.98 0.00893
#>  9     1  1.75  12.2   82.8  37.1  4.14  4.14 0.0104 
#> 10     1  2      9.07  85.0  36.4  4.25  4.25 0.0119 
#> # ℹ 1,950 more rows
```
