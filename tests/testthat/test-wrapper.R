library(testthat)
library(mrgsim.ds)

test_that("mrgsolve wrappers", {
  x <- modlib_ds("pk1", param = list(CL = 2), compile = FALSE)
  expect_is(x, "mrgmod")
  expect_equal(x$CL, 2)
  l <- as.list(x@envir)
  expect_true(l$mrgsim.ds.mread_valid)
  expect_equal(l$mrgsim.ds.mread_pid, Sys.getpid())
  expect_equal(
    normalizePath(dirname(l$mrgsim.ds.mread_tempdir), mustWork = TRUE),
    normalizePath(tempdir(), mustWork = TRUE)
  )
  
  code <- "$param a = 1"
  x <- mcode_ds("example-mcode", code, end = 12, compile = FALSE)
  expect_is(x, "mrgmod")
  expect_equal(x$end, 12)
  
  tmp <- tempfile()
  cat(code, file = tmp, sep = "\n")
  x <- mread_ds(tmp, delta = 5, compile = FALSE)
  expect_is(x, "mrgmod")
  expect_equal(x$delta, 5)
  
  x <- mread_cache_ds(tmp, rtol = 1e-2, compile = FALSE)
  expect_is(x, "mrgmod")
  expect_equal(x$rtol, 1e-2)
})
mrgsim.ds:::teardown_ds()
