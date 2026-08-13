library(testthat)
library(mrgsim.ds)

mod <- house_ds(end = 3, delta = 1)

test_that("reduce lists of simulations", {
  x <- list(mrgsim_ds(mod), mrgsim_ds(mod), mrgsim_ds(mod))
  out <- reduce_ds(x)
  expect_is(out, "mrgsimsds")
  expect_length(out$files, 3)
  
  x <- list(mrgsim_ds(mod), mrgsim_ds(mod), letters, mrgsim_ds(mod))
  expect_error(reduce_ds(x), "must inherit from ")
  
  out <- reduce_ds(mrgsim_ds(mod))
  expect_is(out, "mrgsimsds")
  expect_length(out$files,1)
})

test_that("ok to reduce", {
  expect_error(reduce_ds(list()), "must not be empty")

  a <- mrgsim_ds(mod, gc = FALSE)
  b <- mrgsim_ds(mod, gc = FALSE)
  c <- mrgsim_ds(mod, gc = FALSE)
  
  bb <- copy_ds(b)
  bb$names <- letters
  x <- list(a,bb,c)
  expect_error(reduce_ds(x), "must have the same column names")
  
  bb <- copy_ds(b)
  bb$files <- 'a'
  x <- list(a,bb,c)
  expect_error(reduce_ds(x), "parquet files do not exist")
  
  bb <- copy_ds(b)
  bb$files <- a$files
  x <- list(a,bb,c)
  expect_error(reduce_ds(x), "must have unique file names")
  
  bb <- copy_ds(b)
  bb$mod@model <- "wrong-model"
  x <- list(a, bb, c)
  expect_error(reduce_ds(x))
})

test_that("can reduce if all are owned by object", {
  out <- lapply(1:3, \(x) mrgsim_ds(mod, end = 1))   
  expect_is(reduce_ds(out), "mrgsimsds")
})

test_that("can reduce if none are owned", {
  out <- lapply(1:3, \(x) mrgsim_ds(mod, end = 1))   
  out <- lapply(out, disown)
  expect_is(reduce_ds(out), "mrgsimsds")
})

test_that("can reduce if no one else owns", {
  out <- lapply(1:3, \(x) mrgsim_ds(mod, end = 1))   
  out[c(1,3)] <- lapply(out[c(1,3)], disown)
  expect_is(reduce_ds(out), "mrgsimsds")
})

test_that("can't reduce if one file is owned by another object", {
  x <- mrgsim_ds(mod, end = 1)
  out <- lapply(1:3, \(x) mrgsim_ds(mod, end = 1))
  out <- lapply(out, take_ownership)
  mrgsim.ds:::transfer_ownership(out[[2]], x$address)
  expect_error(reduce_ds(out), "another object cannot own files")
})

rm(mod)
mrgsim.ds:::teardown_ds()
