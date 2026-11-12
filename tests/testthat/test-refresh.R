library(testthat)
library(mrgsim.ds)

test_that("refresh invalid pointers", {
  mod <- house_ds(end = 3, delta = 1)
  out <- mrgsim_ds(mod)
  out$ds$set_pointer(new("externalptr"))
  expect_true(mrgsim.ds:::invalid_ds(out))
  out <- refresh_ds(out)
  expect_false(mrgsim.ds:::invalid_ds(out))

  out$ds$set_pointer(new("externalptr"))
  expect_true(mrgsim.ds:::invalid_ds(out))
  out <- reduce_ds(out)
  expect_false(mrgsim.ds:::invalid_ds(out))
  
  l <- list(mrgsim_ds(mod), mrgsim_ds(mod), mrgsim_ds(mod))
  x <- refresh_ds(l)
  expect_is(l, "list")
  v <- sapply(l, mrgsim.ds:::invalid_ds)  
  expect_all_false(v)
})
test_that("refresh does not change mread_pid", {
  mod <- house_ds(end = 3, delta = 1)
  out <- mrgsim_ds(mod)
  expect_null(out$mod)
  expect_identical(out$mread_pid, Sys.getpid())
  out$mread_pid <- -123456789
  out$pid <- -123456789
  out <- refresh_ds(out)
  expect_identical(out$pid, Sys.getpid())
  expect_identical(out$mread_pid, -123456789)
  expect_true(mrgsim.ds:::pid_changed(out))
  out$gc <- FALSE
})

mrgsim.ds:::teardown_ds()
