library(testthat)
library(mrgsim.ds)

mod <- house_ds(end = 3, delta = 1)

test_that("combine_ds reduces multiple files to one", {
  out <- reduce_ds(lapply(1:3, \(x) mrgsim_ds(mod)))
  expect_length(out$files, 3)
  combine_ds(out)
  expect_length(out$files, 1)
  expect_true(file.exists(out$files))
})

test_that("combine_ds is a no-op with a single backing file", {
  out <- mrgsim_ds(mod)
  file_before <- out$files
  combine_ds(out)
  expect_length(out$files, 1)
  expect_equal(out$files, file_before)
})

test_that("combine_ds: resulting file stays in the same directory", {
  out <- reduce_ds(lapply(1:3, \(x) mrgsim_ds(mod)))
  original_dir <- dirname(out$files[[1]])
  combine_ds(out)
  expect_equal(dirname(out$files[[1]]), original_dir)
})

test_that("combine_ds: original backing files are deleted", {
  out <- reduce_ds(lapply(1:3, \(x) mrgsim_ds(mod)))
  originals <- out$files
  combine_ds(out)
  removed <- setdiff(originals, out$files)
  expect_length(removed, 3)
  expect_false(any(file.exists(removed)))
})

test_that("combine_ds: data is preserved", {
  out <- reduce_ds(lapply(1:3, \(x) mrgsim_ds(mod)))
  original_data <- dplyr::collect(out)
  combine_ds(out)
  expect_equal(dplyr::collect(out), original_data)
})

test_that("combine_ds: gc flag is unchanged", {
  out <- reduce_ds(lapply(1:3, \(x) mrgsim_ds(mod)))
  gc_before <- out$gc
  combine_ds(out)
  expect_equal(out$gc, gc_before)
})

test_that("combine_ds: ownership is maintained", {
  out <- reduce_ds(lapply(1:3, \(x) mrgsim_ds(mod)))
  combine_ds(out)
  expect_true(check_ownership(out))
})

test_that("combine_ds errors without ownership", {
  out <- reduce_ds(lapply(1:3, \(x) mrgsim_ds(mod)))
  disown(out)
  expect_error(combine_ds(out), "don't own")
})

rm(mod)
mrgsim.ds:::teardown_ds()
