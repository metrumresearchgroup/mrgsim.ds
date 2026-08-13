library(testthat)
library(mrgsim.ds)

test_that("require ds", {
  mod <- house_ds()
  out <- mrgsim_ds(mod)
  expect_null(mrgsim.ds:::require_ds(out))
  expect_error(mrgsim.ds:::require_ds(letters), "not 'character'")
  expect_error(mrgsim.ds:::require_ds(mtcars), "not 'data.frame'")
})

test_that("format numbers for print", {
  x <- mrgsim.ds:::format_big()(1234)  
  expect_equal(x, "1.2K")

  x <- mrgsim.ds:::format_big()(123456789)  
  expect_equal(x, "123.5M")
})

test_that("is_mrgsimsds", {
  mod <- house_ds()
  expect_false(is_mrgsimsds(mod))

  out <- mrgsim_ds(mod)
  expect_true(is_mrgsimsds(out))
})

test_that("save_process_info", {
  mod <- mrgsolve::house()
  expect_null(mod@envir$mrgsim.ds.mread_pid)
  mod <- save_process_info(mod)
  expect_identical(mod@envir$mrgsim.ds.mread_pid, Sys.getpid())
})

test_that("check if pid changed", {
  mod <- house_ds(end = 1)
  expect_false(mrgsim.ds:::pid_changed(mod))
  
  mod@envir$mrgsim.ds.mread_pid <- -123456789
  expect_true(mrgsim.ds:::pid_changed(mod))
  
  mod <- house_ds(end = 1)
  out <- mrgsim_ds(mod)
  expect_false(mrgsim.ds:::pid_changed(out))
})
mrgsim.ds:::teardown_ds()
